#!/bin/bash
set -euo pipefail

# hypr
rm ~/.config/hypr -r
ln -s ~/.config/hyprland/hypr ~/.config/hypr

# mpv
rm ~/.config/mpv -r
ln -s ~/.config/hyprland/mpv ~/.config/mpv

# pgcli
rm ~/.config/pgcli -r
ln -s ~/.config/hyprland/pgcli ~/.config/pgcli

# btop
rm ~/.config/btop -r
ln -s ~/.config/hyprland/btop ~/.config/btop

# dunst
rm ~/.config/dunst -r
ln -s ~/.config/hyprland/dunst ~/.config/dunst

# fastfetch
rm ~/.config/fastfetch -r
ln -s ~/.config/hyprland/fastfetch ~/.config/fastfetch

# firefox
rm ~/.config/firefox -r
ln -s ~/.config/hyprland/firefox ~/.config/firefox

# tmux
rm ~/.config/tmux -r
ln -s ~/.config/hyprland/tmux ~/.config/tmux

# waybar
rm ~/.config/waybar -r
ln -s ~/.config/hyprland/waybar ~/.config/waybar

# wofi
rm ~/.config/wofi -r
ln -s ~/.config/hyprland/wofi ~/.config/wofi

# zathura
rm ~/.config/zathura -r
ln -s ~/.config/hyprland/zathura ~/.config/zathura

# mimeapps.list
rm ~/.config/mimeapps.list
ln -s ~/.config/hyprland/mimeapps.list ~/.config/mimeapps.list

# NOTE: uncomment if needed
# amnezia for notebook
# ln -s ~/.config/hyprland/applications/* ~/.local/share/applications

# sddm theme symlinks
sudo ln -s ~/.config/hyprland/LoginTheme/catppuccin-mocha /usr/share/sddm/themes/
sudo ln -s ~/.config/hyprland/LoginTheme/sddm.conf /etc/
