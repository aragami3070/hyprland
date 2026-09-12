#!/usr/bin/env bash

set -uo pipefail

controller_info="$(bluetoothctl show 2>/dev/null || true)"

if [[ -z "$controller_info" ]] || ! grep -q '^Controller ' <<< "$controller_info"; then
    printf 'missing\n\n'
    exit 0
fi

powered="$(awk -F': ' '/^[[:space:]]*Powered:/ { print $2; exit }' <<< "$controller_info")"

if [[ "$powered" != "yes" ]]; then
    printf 'off\n󰂲\n'
    exit 0
fi

connected_count="$(bluetoothctl devices Connected 2>/dev/null \
    | awk '$1 == "Device" { count++ } END { print count + 0 }')"

if (( connected_count > 0 )); then
    printf 'connected\n  %d\n' "$connected_count"
else
    printf 'on\n\n'
fi
