#!/usr/bin/env bash

set -uo pipefail

declare -A total_before
declare -A idle_before

while read -r label user nice system idle iowait irq softirq steal _; do
    [[ "$label" =~ ^cpu[0-9]*$ ]] || break
    total_before["$label"]=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_before["$label"]=$((idle + iowait))
done < /proc/stat

sleep 0.2

while read -r label user nice system idle iowait irq softirq steal _; do
    [[ "$label" =~ ^cpu[0-9]*$ ]] || break

    total_now=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle_now=$((idle + iowait))
    total_delta=$((total_now - total_before[$label]))
    idle_delta=$((idle_now - idle_before[$label]))

    if (( total_delta > 0 )); then
        usage=$(((100 * (total_delta - idle_delta) + total_delta / 2) / total_delta))
    else
        usage=0
    fi

    if [[ "$label" == "cpu" ]]; then
        printf 'all %d\n' "$usage"
    else
        printf '%s %d\n' "${label#cpu}" "$usage"
    fi
done < /proc/stat
