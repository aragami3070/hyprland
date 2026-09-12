#!/bin/bash

set -euo pipefail

green="\033[1;32m"
blue="\033[1;34m"
reset="\033[0m"

tpm_dir="$HOME/.config/tmux/plugins/tpm"

if [[ -d "$tpm_dir/.git" ]]; then
	echo -e "${green}    ✔ TPM is already installed.${reset}"
else
	echo -e "${blue}    Installing TPM...${reset}"
	mkdir -p "$(dirname "$tpm_dir")"
	git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
	echo -e "${green}    ✔ TPM installed.${reset}"
fi

if tmux list-sessions &>/dev/null; then
	tmux source-file "$HOME/.config/tmux/tmux.conf"
	echo -e "${green}    ✔ Tmux config reloaded.${reset}"
else
	echo -e "${blue}    Tmux server is not running; config will load on first start.${reset}"
fi
