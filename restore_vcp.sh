#!/usr/bin/env sh

vcp=$(cat /tmp/vcp/val)

ddcutil setvcp 10 "$vcp"
