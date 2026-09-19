#!/usr/bin/env bash

set -euo pipefail

if (( EUID == 0 )); then
    printf 'Run this setup as the desktop user, not root. It will call sudo itself.\n' >&2
    exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_hook="$repo_dir/networkmanager/dispatcher.d/90-ssu-dns"
destination="/etc/NetworkManager/dispatcher.d/90-ssu-dns"

[[ -f "$source_hook" ]] || { printf 'Missing hook: %s\n' "$source_hook" >&2; exit 1; }

sudo install -D --owner=root --group=root --mode=0755 "$source_hook" "$destination"
printf 'Installed %s\n' "$destination"
