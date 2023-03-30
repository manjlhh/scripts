#!/usr/bin/env sh

mkdir -p /tmp/vcp

vcp=$(ddcutil getvcp 10 | sed 's/.*current value = *\([0-9]*\).*/\1/')

printf "%d" "$vcp" >/tmp/vcp/val

ddcutil setvcp 10 0
