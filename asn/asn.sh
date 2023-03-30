#!/usr/bin/env sh
set -e

SDIR=$(dirname "$(readlink -f "$0")")

function resolve_ip {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    local ip=$(dig +short "$1" | tail -n1)
    echo "${ip:?"no ip resolved for $1"}"
}

function resolve_asn {
    if [ $# -ne 1 ]; then
        exit 1
    fi
    local result=$(timeout --kill-after=3s 4s whois -h bgp.tools "$1" | awk -F' *\\| *' 'NR==2 {print $7}')
    echo "${result:?"no asn resolved for $1"}"
}

urls='
https://rust-lang.org/static/images/ferris.gif
https://runtu.org/images/computer-4146579_1920.jpg
https://fishshell.com/docs/current/relnotes.html

https://crates.io/assets/cargo.png
https://nginx.org/en/docs/dev/development_guide.html
https://nixos.org/blog/
https://www.jetbrains.com/img/home-page/screenshots/idea.svg
https://tailscale.com/

https://docs.nginx.com/css/fonts/jetbrainsmono/JetBrainsMono-Light.woff2

https://zed.dev/
https://codeforces.com/

https://www.apple.com/home/gallery/styles/modal.css
https://www.adobe.com/mas/libs/commerce.js

https://manjaro.org/news/
https://7-zip.org/history.txt
https://kde.org/images/logos/gnupg_dark.svg

https://www.win-rar.com/fileadmin/images/products/winrar-start.png
'

IFS=' ' read -ra url_arr <<< "$(echo "$urls" | xargs)"

mkdir -p /tmp/asn
touch /tmp/asn/seen

seen=$(cat /tmp/asn/seen | xargs)
declare -A seen_set
for pair in "${seen[@]}"; do
    if [ -z "$pair" ]; then
        continue
    fi
    IFS=',' read -ra vals <<< "$pair"
    domain="${vals[0]}"
    asn="${vals[1]}"
    if [ -n "$domain" ]; then
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

    asn=$(resolve_asn "$ip")
    result_arr+=("$domain,$asn")

    echo "$domain" >> /tmp/asn/seen
    seen_set["$domain"]="$asn"
done

IFS=$'\n'; echo "${result_arr[*]}" > "$SDIR/asn"
rm /tmp/asn/seen
