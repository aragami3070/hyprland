#!/bin/bash
# set -euo pipefail

# hypr
mkdir ~/.config/hypr
rm ~/.config/hypr -r
ln -s ~/.config/hyprland/hypr ~/.config/hypr

# mpv
mkdir ~/.config/mpv
rm ~/.config/mpv -r
ln -s ~/.config/hyprland/mpv ~/.config/mpv

# pgcli
mkdir ~/.config/pgcli
rm ~/.config/pgcli -r
ln -s ~/.config/hyprland/pgcli ~/.config/pgcli

# btop
mkdir ~/.config/btop
rm ~/.config/btop -r
ln -s ~/.config/hyprland/btop ~/.config/btop

# dunst
mkdir ~/.config/dunst
rm ~/.config/dunst -r
ln -s ~/.config/hyprland/dunst ~/.config/dunst

# fastfetch
mkdir ~/.config/fastfetch
rm ~/.config/fastfetch -r
ln -s ~/.config/hyprland/fastfetch ~/.config/fastfetch

# firefox
mkdir ~/.config/firefox
rm ~/.config/firefox -r
ln -s ~/.config/hyprland/firefox ~/.config/firefox

# tmux
mkdir ~/.config/tmux
rm ~/.config/tmux -r
ln -s ~/.config/hyprland/tmux ~/.config/tmux

# waybar
mkdir ~/.config/waybar
rm ~/.config/waybar -r
ln -s ~/.config/hyprland/waybar ~/.config/waybar

# wofi
mkdir ~/.config/wofi
rm ~/.config/wofi -r
ln -s ~/.config/hyprland/wofi ~/.config/wofi

# zathura
mkdir ~/.config/zathura
rm ~/.config/zathura -r
ln -s ~/.config/hyprland/zathura ~/.config/zathura

# mimeapps.list
touch ~/.config/mimeapps.list
rm ~/.config/mimeapps.list
ln -s ~/.config/hyprland/mimeapps.list ~/.config/mimeapps.list

# NOTE: uncomment if needed
# amnezia for notebook
# ln -s ~/.config/hyprland/applications/* ~/.local/share/applications

# sddm theme symlinks
sudo mkdir /usr/share/sddm/themes/catppuccin-mocha/
sudo cp -r ~/.config/hyprland/LoginTheme/catppuccin-mocha/* /usr/share/sddm/themes/catppuccin-mocha/
sudo ln -s ~/.config/hyprland/LoginTheme/sddm.conf /etc/
