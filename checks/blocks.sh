#!/usr/bin/env sh

SDIR=$(dirname "$(readlink -f "$0")")

. "$SDIR/cfg"

IFS=' ' read -ra url_arr <<< "$(echo "$urls" | xargs)"

# for url in "${url_arr[@]}"; do

# done

size=$(curl -s -o/dev/null https://lobste.rs/ -w '%{size_download}' --max-time 5)
code="$?"

