#!/bin/bash

currnet_wallpaper=$(hyprctl hyprpaper listactive | head -n1 | awk -F'=' '{print $2}')
monitor_name=$(hyprctl monitors | grep Monitor | awk '{print $2}')

hyprctl hyprpaper wallpaper "$monitor_name,$(ls /home/aragami3070/.config/hypr/Wallpapers/Other/*.png | grep -v "$currnet_wallpaper" | shuf -n 1)"
