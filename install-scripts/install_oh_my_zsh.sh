#!/bin/bash

# If get error then exit
set -euo pipefail

# Colors for output
green="\033[1;32m"
blue="\033[1;34m"
red="\033[1;31m"
reset="\033[0m"

check_command() {
	command -v "$1" &>/dev/null
}

# Install Amnezia
if check_command "omz"; then
	echo -e "${green}    ✔ oh-my-zsh is already installed.${reset}"
else
    echo -e "${blue}    Installing oh-my-zsh ...${reset}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions
    git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
    echo -e "${green}    ✔ oh-my-zsh installed.${reset}"
fi

if check_command "p10k"; then
	echo -e "${green}    ✔ powerlevel10k is already installed.${reset}"
else
    echo -e "${blue}    Installing powerlevel10k ...${reset}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    echo -e "${green}    ✔ powerlevel10k installed.${reset}"
fi
