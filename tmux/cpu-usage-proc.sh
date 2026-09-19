#!/usr/bin/env bash

# Lightweight tmux CPU meter. Keep the previous /proc/stat counters in the
# per-user runtime directory so each status refresh only needs one snapshot.

IFS=' ' read -r label user nice system idle iowait irq softirq steal _ < /proc/stat

if [[ $label != cpu ]]; then
    printf '  --%%\n'
    exit 0
fi

user=${user:-0}
nice=${nice:-0}
system=${system:-0}
idle=${idle:-0}
iowait=${iowait:-0}
irq=${irq:-0}
softirq=${softirq:-0}
steal=${steal:-0}

total=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_total=$((idle + iowait))

tmux_fields=${TMUX#*,}
tmux_server_pid=${tmux_fields%%,*}
runtime_dir=${XDG_RUNTIME_DIR:-/tmp}
state_file="$runtime_dir/tmux-cpu-${tmux_server_pid:-$UID}.state"

previous_total=
previous_idle=
previous_usage=
if [[ -r $state_file ]]; then
    IFS=' ' read -r previous_total previous_idle previous_usage < "$state_file"
fi

usage=$previous_usage
if [[ $previous_total =~ ^[0-9]+$ && $previous_idle =~ ^[0-9]+$ && $total -gt $previous_total ]]; then
    total_delta=$((total - previous_total))
    idle_delta=$((idle_total - previous_idle))
    usage=$(((100 * (total_delta - idle_delta) + total_delta / 2) / total_delta))
    ((usage < 0)) && usage=0
    ((usage > 100)) && usage=100
fi

printf '%s %s %s\n' "$total" "$idle_total" "${usage:-0}" > "$state_file"
if [[ $usage =~ ^[0-9]+$ ]]; then
    printf '  %d%%\n' "$usage"
else
    printf '  --%%\n'
fi
