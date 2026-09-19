#!/usr/bin/env bash

set -euo pipefail

if (( EUID == 0 )); then
    printf 'Run this setup as the desktop user, not root.\n' >&2
    exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
unit_dir="$repo_dir/daemons/low-battery-notifier"
user_unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
service_name="low-battery-notifier.service"
source="$unit_dir/$service_name"
destination="$user_unit_dir/$service_name"

[[ -f "$source" ]] || { printf 'Missing unit: %s\n' "$source" >&2; exit 1; }

if [[ -L "$destination" ]]; then
    if [[ "$(readlink -f -- "$destination")" != "$(readlink -f -- "$source")" ]]; then
        printf 'Another unit already uses %s\n' "$destination" >&2
        exit 1
    fi
elif [[ -e "$destination" ]]; then
    printf 'Another unit already uses %s\n' "$destination" >&2
    exit 1
else
    systemctl --user link "$source"
fi

# Remove the old polling timer installed by earlier versions. The notifier is
# now started by Quickshell when UPower emits a battery change signal.
systemctl --user disable --now low-battery-notifier.timer 2>/dev/null || true

legacy_timer="$user_unit_dir/low-battery-notifier.timer"
legacy_wants="$user_unit_dir/timers.target.wants/low-battery-notifier.timer"
[[ -L "$legacy_wants" ]] && rm -- "$legacy_wants"
[[ -L "$legacy_timer" ]] && rm -- "$legacy_timer"

systemctl --user daemon-reload
systemctl --user reset-failed low-battery-notifier.timer 2>/dev/null || true
printf 'Installed the event-driven low battery notifier; no timer is active.\n'
