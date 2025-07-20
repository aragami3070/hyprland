#!/bin/bash

monitor_name=$(hyprctl monitors | grep Monitor | awk '{print $2}')

# start on all computers
hyprctl dispatch exec [ workspace 1 silent] firefox
hyprctl dispatch exec [workspace special:magic silent] kitty

# start on desktop with DP-2 (my desktop)
if [ $monitor_name == "DP-2" ]; then
	hyprctl dispatch exec [ workspace 2 silent] chromium
	hyprctl dispatch exec [ workspace 3 silent] Telegram
fi
