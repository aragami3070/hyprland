#!/bin/bash

# If get error then exit
set -euo pipefail

git clone git@github.com:aragami3070/zsh.git ~/.config/

rm ~/.zshrc

ln -s ~/.config/zsh/.editorconfig ~/.editorconfig
ln -s ~/.config/zsh/.gitconfig ~/.gitconfig
ln -s ~/.config/zsh/.p10k.zsh ~/.p10k.zsh
ln -s ~/.config/zsh/.zshrc ~/.zshrc

mkdir ~/.bin -p
ln -s ~/.config/zsh/change_git_config.sh ~/.bin/change_git_config
