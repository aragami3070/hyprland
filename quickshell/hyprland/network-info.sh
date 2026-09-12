#!/usr/bin/env bash
set -u

wifi_device=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')

if [[ -n "$wifi_device" ]]; then
    signal_strength=$(nmcli -t -f IN-USE,SIGNAL device wifi list ifname "$wifi_device" 2>/dev/null \
        | awk -F: '$1 == "*" { print $2; exit }')
    ip_address=$(ip -4 -o address show dev "$wifi_device" scope global 2>/dev/null \
        | awk '{ sub(/\/.*/, "", $4); print $4; exit }')

    printf '  %s%%\n%s\n' "${signal_strength:---}" "${ip_address:-IP: —}"
    exit 0
fi

ethernet_device=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "ethernet" && $3 == "connected" { print $1; exit }')

if [[ -n "$ethernet_device" ]]; then
    cidr=$(ip -4 -o address show dev "$ethernet_device" scope global 2>/dev/null \
        | awk '{ print $4; exit }')
    ip_address=${cidr%/*}

    printf '%s  \n%s\n' "${cidr:-}" "${ip_address:-IP: —}"
    exit 0
fi

printf '⚠\nIP: —\n'
