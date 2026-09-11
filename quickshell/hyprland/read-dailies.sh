#!/usr/bin/env bash

set -u

dailies_dir=${1:?dailies directory is required}

while IFS= read -r -d '' note; do
    printf '@@QS_FILE@@%s\n' "$note"
    command cat -- "$note"
    printf '\n'
done < <(find "$dailies_dir" -type f -name '*.md' -print0 | sort -z)
