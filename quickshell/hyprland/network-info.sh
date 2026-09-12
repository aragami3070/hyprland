#!/usr/bin/env bash
set -u

wifi_device=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "wifi" && $3 == "connected" { print $1; exit }')

if [[ -n "$wifi_device" ]]; then
    signal_strength=$(nmcli -t -f IN-USE,SIGNAL device wifi list ifname "$wifi_device" 2>/dev/null \
        | awk -F: '$1 == "*" { print $2; exit }')
    ssid=$(nmcli -t --escape no -f IN-USE,SSID device wifi list ifname "$wifi_device" 2>/dev/null \
        | awk 'substr($0, 1, 2) == "*:" { print substr($0, 3); exit }')
    cidr=$(ip -4 -o address show dev "$wifi_device" scope global 2>/dev/null \
        | awk '{ print $4; exit }')
    network_name=${ssid:-$wifi_device}

    if [[ -n "$cidr" ]]; then
        wifi_text="  ${signal_strength:---}%"
        wifi_ip_text="$wifi_device @ $network_name: $cidr"
    else
        wifi_text="  ${signal_strength:---}%"
        wifi_ip_text="$wifi_device @ $network_name: IP —"
    fi
else
    wifi_text="⚠"
    wifi_ip_text="IP: —"
fi

ethernet_device=$(nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
    | awk -F: '$2 == "ethernet" && $3 == "connected" { print $1; exit }')

if [[ -n "$ethernet_device" ]]; then
    cidr=$(ip -4 -o address show dev "$ethernet_device" scope global 2>/dev/null \
        | awk '{ print $4; exit }')

    ethernet_text="󰈀"
    ethernet_ip_text="$ethernet_device: ${cidr:-IP —}"
else
    ethernet_text=""
    ethernet_ip_text=""
fi

printf '%s\n%s\n%s\n%s\n' \
    "$wifi_text" "$wifi_ip_text" "$ethernet_text" "$ethernet_ip_text"
