#!/bin/bash

# If get error then exit
set -euo pipefail

green="\033[1;32m"
blue="\033[1;34m"
red="\033[1;31m"
reset="\033[0m"

zsh_config_dir="$HOME/.config/zsh"

if [[ -d "$zsh_config_dir/.git" ]]; then
	echo -e "${green}    ✔ Zsh config is already installed.${reset}"
else
	echo -e "${blue}    Installing Zsh config...${reset}"
	git clone git@github.com:aragami3070/zsh.git "$zsh_config_dir"
	echo -e "${green}    ✔ Zsh config installed.${reset}"
fi

ensure_symlink() {
	local source_file="$1"
	local target_file="$2"

	if [[ -L "$target_file" ]] \
		&& [[ "$(readlink -f -- "$target_file")" == "$(readlink -f -- "$source_file")" ]]; then
		echo -e "${green}    ✔ $target_file is already linked.${reset}"
		return
	fi

	if [[ -e "$target_file" || -L "$target_file" ]]; then
		echo -e "${red}    $target_file already exists and points elsewhere.${reset}" >&2
		exit 1
	fi

	ln -s "$source_file" "$target_file"
	echo -e "${green}    ✔ Linked $target_file.${reset}"
}

mkdir -p "$HOME/.bin"
ensure_symlink "$zsh_config_dir/.editorconfig" "$HOME/.editorconfig"
ensure_symlink "$zsh_config_dir/.gitconfig" "$HOME/.gitconfig"
ensure_symlink "$zsh_config_dir/.p10k.zsh" "$HOME/.p10k.zsh"
ensure_symlink "$zsh_config_dir/.zshrc" "$HOME/.zshrc"
ensure_symlink "$zsh_config_dir/change_git_config.sh" "$HOME/.bin/change_git_config"
