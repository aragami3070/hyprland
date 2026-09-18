#!/usr/bin/env bash

set -euo pipefail

if (( EUID == 0 )); then
    printf 'Run this setup as the desktop user, not root.\n' >&2
    exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
unit_dir="$repo_dir/daemons/low-battery-notifier"
user_unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
units_to_link=()

for suffix in service timer; do
    name="low-battery-notifier.$suffix"
    source="$unit_dir/$name"
    destination="$user_unit_dir/$name"

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
        units_to_link+=("$source")
    fi
done

if (( ${#units_to_link[@]} > 0 )); then
    systemctl --user link "${units_to_link[@]}"
fi

systemctl --user daemon-reload
systemctl --user enable --now low-battery-notifier.timer
