#!/bin/bash

# If get error then exit
set -euo pipefail

# Colors for output
green="\033[1;32m"
blue="\033[1;34m"
red="\033[1;31m"
reset="\033[0m"

AmneziaInstall() {
	echo -e "${blue}    Installing yay...${reset}"
	mkdir "$HOME/Amnezia"
	cd "$HOME/Amnezia"
	wget https://github.com/amnezia-vpn/amnezia-client/releases/download/4.8.3.1/AmneziaVPN_4.8.3.1_linux.tar.zip
	unzip AmneziaVPN_4.8.3.1_linux.tar.zip
	tar -xvf AmneziaVPN_Linux_Installer.ta
	chmod +x AmneziaVPN_Linux_Installer.bin
	sudo ./AmneziaVPN_Linux_Installer.bin
	cd - &>/dev/null
	echo -e "${green}    Amnezia installed...${reset}"
}
