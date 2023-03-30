#!/usr/bin/env sh
set -e

SDIR=$(dirname "$(readlink -f "$0")")

. "$SDIR/cfg"

function resolve_ip {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    local ip=$(dig +short "$1" | grep -Eo '[0-9.]{7,15}' | head -1)
    echo "${ip:?"no ip resolved for $1"}"
}

function resolve_asn {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    local result=$(timeout --kill-after=3s 4s whois -h bgp.tools "$1" | awk -F' *\\| *' 'NR==2 {print $7}')
    echo "${result:?"no asn resolved for $1"}"
}

function resolve_asn2 {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    local asns=$(curl --max-time 4s "https://stat.ripe.net/data/prefix-overview/data.json?resource=$1" | jq -r '[.data.asns.[].holder] | join(", ")')
    echo "${asns:?"no asn resolved for $1"}"
}

# https://stat.ripe.net/data/prefix-overview/data.json?resource=1.1.1.1

IFS=' ' read -ra url_arr <<< "$(echo "$urls" | xargs)"

mkdir -p /tmp/asn
touch /tmp/asn/seen

mapfile -t seen_arr < /tmp/asn/seen
declare -A seen_set
for line in "${seen_arr[@]}"; do
    if [ -z "$line" ]; then
        continue
    fi
    IFS='|' read -ra vals <<< "$line"
    domain="${vals[0]}"
    asn="${vals[1]}"
    if [ -n "$domain" ]; then
        echo "already resolved $domain ~ $asn"
        seen_set["$domain"]="$asn"
    fi
done

declare -a result_arr
for url in "${url_arr[@]}"; do
    domain=$(echo "$url" | awk -F[:/] '{ printf $4 }')
    asn="${seen_set["$domain"]}"
    if [ ! -z "$asn" ]; then
        echo "skip $domain"
        result_arr+=("$domain,$asn")
        continue
    fi

    ip=$(resolve_ip "$domain")
    echo "$domain - $ip"

    asn=$(resolve_asn2 "$ip")
    result_arr+=("$domain,$asn")

    echo "$domain|$asn" >> /tmp/asn/seen
    seen_set["$domain"]="$asn"
done

echo "HOST,ASN" > "$SDIR/asn"
IFS=$'\n'; echo "${result_arr[*]}" >> "$SDIR/asn"
echo "COMPLETED"
