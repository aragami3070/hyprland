#!/usr/bin/env bash
set -u

daily_file=${1:?daily file is required}
session_name=obsidian
vault_directory=${QS_OBSIDIAN_VAULT:-/home/aragami3070/ObsidianWorkSpace/Obsidian}
runtime_directory=${XDG_RUNTIME_DIR:-/tmp}
nvim_socket=${QS_OBSIDIAN_NVIM_SOCKET:-${runtime_directory}/nvim-obsidian-${UID}.sock}

if [[ ! -f "$daily_file" ]]; then
    notify-send -i dialog-error "Obsidian daily" "Daily-файл не найден"
    exit 1
fi

tmux_command=(tmux)
if [[ -n "${QS_TMUX_SOCKET:-}" ]]; then
    tmux_command+=(-L "$QS_TMUX_SOCKET")
fi

run_tmux() {
    "${tmux_command[@]}" "$@"
}

if ! run_tmux has-session -t "=${session_name}" 2>/dev/null; then
    notify-send -i dialog-error "Obsidian tmux" "Сессия obsidian не запущена"
    exit 1
fi

nvim_pane=$(run_tmux list-panes -s -t "=${session_name}" \
    -F '#{pane_id}|#{pane_current_command}' \
    | awk -F '|' '$2 == "nvim" { print $1; exit }')

if [[ -n "$nvim_pane" ]]; then
    if [[ -S "$nvim_socket" ]] \
        && nvim --server "$nvim_socket" --remote-expr '1' >/dev/null 2>&1; then
        nvim --server "$nvim_socket" --remote "$daily_file"
    else
        vim_path=${daily_file//\'/\'\'}
        run_tmux send-keys -t "$nvim_pane" Escape
        run_tmux send-keys -t "$nvim_pane" -l ":execute 'edit ' . fnameescape('${vim_path}')"
        run_tmux send-keys -t "$nvim_pane" Enter
    fi
    target_pane=$nvim_pane
else
    target_pane=$(run_tmux list-panes -s -t "=${session_name}" \
        -F '#{pane_id}|#{pane_current_command}|#{pane_active}' \
        | awk -F '|' '$3 == "1" && $2 ~ /^(ba|z|fi|da)?sh$/ { print $1; exit }')

    if [[ -z "$target_pane" ]]; then
        target_pane=$(run_tmux new-window -d -P -F '#{pane_id}' \
            -t "=${session_name}" -n daily -c "$vault_directory")
    fi

    printf -v quoted_socket '%q' "$nvim_socket"
    printf -v quoted_file '%q' "$daily_file"
    run_tmux send-keys -t "$target_pane" -l \
        "nvim --listen ${quoted_socket} -- ${quoted_file}"
    run_tmux send-keys -t "$target_pane" Enter
fi

run_tmux select-pane -t "$target_pane"

attached_client=$(run_tmux list-clients \
    -F '#{client_activity}|#{client_name}' 2>/dev/null \
    | sort -nr \
    | awk -F '|' 'NR == 1 { print $2 }')

if [[ -n "$attached_client" ]]; then
    run_tmux switch-client -c "$attached_client" -t "$target_pane"
fi
