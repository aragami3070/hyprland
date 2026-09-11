#!/usr/bin/env bash
set -u

task_file=${1:?task file is required}
task_line=${2:?task line is required}
new_status=${3:?new status is required}

case "$new_status" in
    " "|x|\>|-|!|i) ;;
    *)
        printf 'unsupported task status: %s\n' "$new_status" >&2
        exit 2
        ;;
esac

if [[ ! -f "$task_file" || ! "$task_line" =~ ^[0-9]+$ ]]; then
    exit 1
fi

temporary_file=$(mktemp "${task_file}.quickshell.XXXXXX")
cleanup() {
    rm -f -- "$temporary_file"
}
trap cleanup EXIT

awk -v target_line="$task_line" -v status="$new_status" '
    NR == target_line {
        sub(/\[[^]]\]/, "[" status "]")
    }
    { print }
' "$task_file" > "$temporary_file" || exit 1

if ! chmod --reference="$task_file" "$temporary_file"; then
    exit 1
fi

mv -- "$temporary_file" "$task_file"
trap - EXIT
