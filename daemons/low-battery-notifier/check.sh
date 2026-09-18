#!/usr/bin/env bash

set -euo pipefail

# Use the same laptop battery selection as the existing status bar script.
battery_dir="${LOW_BATTERY_BATTERY_DIR:-}"
if [[ -z "$battery_dir" ]]; then
    for candidate in /sys/class/power_supply/BAT*; do
        if [[ -d "$candidate" ]]; then
            battery_dir="$candidate"
            break
        fi
    done
fi

[[ -n "$battery_dir" && -r "$battery_dir/capacity" && -r "$battery_dir/status" ]] || exit 0
IFS= read -r capacity < "$battery_dir/capacity" || exit 0
IFS= read -r status < "$battery_dir/status" || exit 0
[[ "$capacity" =~ ^[0-9]+$ ]] || exit 0
capacity=$((10#$capacity))
(( capacity <= 100 )) || exit 0

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/low-battery-notifier/last-threshold"
last_threshold=15
if [[ -r "$state_file" ]]; then
    IFS= read -r last_threshold < "$state_file" || true
    [[ "$last_threshold" =~ ^(0|2|4|6|8|10|12|14|15)$ ]] || last_threshold=15
fi

# A charge above the warning range starts a new discharge cycle.
if (( capacity >= 15 )); then
    if (( last_threshold < 15 )); then
        printf '15\n' > "$state_file"
    fi
    exit 0
fi

[[ "$status" == Discharging ]] || exit 0

# At 13%, for example, the 14% threshold has been crossed; at 12%,
# the next threshold has been crossed. A skipped reading yields one alert.
threshold=$((capacity + capacity % 2))
(( threshold < last_threshold )) || exit 0

urgency=normal
if (( capacity <= 6 )); then
    urgency=critical
fi

"${LOW_BATTERY_NOTIFY_BIN:-dunstify}" \
    -a low-battery-notifier \
    -u "$urgency" \
    -t 10000 \
    -h string:x-dunst-stack-tag:low-battery \
    -i battery-caution \
    'Низкий заряд батареи' \
    "Осталось ${capacity}%. Подключите зарядное устройство."

# Save state only after the notification was accepted, so failures retry.
mkdir -p "${state_file%/*}"
printf '%s\n' "$threshold" > "$state_file"
