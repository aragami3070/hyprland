#!/bin/bash

# If get error then exit
set -euo pipefail

# Colors for output
green="\033[1;32m"
blue="\033[1;34m"
red="\033[1;31m"
reset="\033[0m"

printBanner() {
    echo -e "${green}   ╭────────────────────────────────────────────────────────────────────────────────────────────────╮${reset}"
    echo -e "${green}   │      A          R R R R          A             G G G           A          M           M    O   │${reset}"
    echo -e "${green}   │    A   A        R     R        A   A          G     G        A   A        M M       M M    I   │${reset}"
    echo -e "${green}   │   A     A       R R R R       A     A        G              A     A       M   M   M   M    I   │${reset}"
    echo -e "${green}   │  A A A A A      R R          A A A A A      G     G G      A A A A A      M     M     M    I   │${reset}"
    echo -e "${green}   │ A         A     R   R       A         A      G      G     A         A     M           M    I   │${reset}"
    echo -e "${green}   │A           A    R     R    A           A      G G G G    A           A    M           M    I   │${reset}"
    echo -e "${green}   ├────────────────────────────────────────────────────────────────────────────────────────────────┤${reset}"
    echo -e "${green}   │H     H    Y       Y    P P P P    R R R R    L                A          N         N    D D D  │${reset}"
    echo -e "${green}   │H     H      Y   Y      P     P    R     R    L              A   A        N N       N    D     D│${reset}"
    echo -e "${green}   │H H H H        Y        P P P P    R R R R    L             A     A       N   N     N    D     D│${reset}"
    echo -e "${green}   │H     H        Y        P          R R        L            A A A A A      N     N   N    D     D│${reset}"
    echo -e "${green}   │H     H        Y        P          R   R      L           A         A     N       N N    D     D│${reset}"
    echo -e "${green}   │H     H        Y        P          R     R    L L L L    A           A    N         N    D D D  │${reset}"
    echo -e "${green}   ╰────────────────────────────────────────────────────────────────────────────────────────────────╯${reset}"
}

abortIfNotArch() {
    if ! grep -q "arch" /etc/os-release; then
        echo -e "${red}    This script is designed to run on Arch Linux. Exiting.${reset}"
        exit 1
	else
		echo -e "${green}    Nice system choice ^_^${reset}"
    fi
}

abortIfRoot() {
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${red}    Please do not run this script as root. Exiting.${reset}"
        exit 1
	else
		echo -e "${green}    Welcome $USER${reset}"
    fi
}

yayInstall() {
	echo -e "${blue}    Installing yay...${reset}"
    git clone https://aur.archlinux.org/yay.git "${HOME}/yay"
	cd "$HOME/yay"
	makepkg -si --noconfirm
	cd - &>/dev/null
	echo -e "${green}    ✔ Yay installed successfully.${reset}"
}

AmneziaInstall() {
	mkdir "$HOME/Amnezia"
	cd "$HOME/Amnezia"
	wget https://github.com/amnezia-vpn/amnezia-client/releases/download/4.8.3.1/AmneziaVPN_4.8.3.1_linux.tar.zip
	unzip AmneziaVPN_4.8.3.1_linux.tar.zip
	tar -xvf AmneziaVPN_Linux_Installer.ta
	chmod +x AmneziaVPN_Linux_Installer.bin
	cd - &>/dev/null
	# TODO: Figure out how to automate the build
	# sudo ./AmneziaVPN_Linux_Installer.bin
}


# TODO:
# 1. Figure out how to automate the build from AmneziaInstall
# 2. Write setup main (all setup)
# 3. Write setup oh-my-zsh
# 4. Add checking if yay and amnezia are installed

# NOTE: Work in progress
packagesInstall() {
	# Install yay
	yayInstall

	# Install Amnezia
	# AmneziaInstall

	echo -e "${blue}    Installing required packages...${reset}"
	# pacman install without confirm and not reinstall installed packages
	sudo pacman -Syu --noconfirm --needed \
		zsh gcc nvim ripgrep wl-clipboard pipewire pam  brightnessctl thunar zip unzip python3 \
		firefox chromium telegram-desktop curl npm yarn cmake eza fastfetch tmux postgres docker \
		docker-comopose hyprlock hyprpaper waybar nwg-look ttf-ubuntu-nerd wofi zoxide zathura \
		metasploit virtualbox typescript vue-typescript-plugin qt6-svg qt6-declarative qt5-quickcontrols2\
		man-pages-ru tldr python-pygments python-pip dotnet-runtime-8.0 aspnet-runtime-8.0 gtk-engine-murrine \
		meson wlogout mpv nmap gnu-netcat ghidra

	# yay install without confirm and not reinstall installed packages
	yay -Syu --noconfirm --needed \
		texlive texlive-fontsextra texlive-langcyrillic hyprshot burpsuite gobuster zoom
	
	# cargo install
	cargo install typst-cli

	echo -e "${green}    ✔ Packages installed.${reset}"
}

# Preparation to installation
abortIfNotArch
abortIfRoot
printBanner

# Installing packages and tools
echo -e "${blue}    Installing packages and tools...${reset}"
packagesInstall
echo -e "${green}    ✔ Packages installed.${reset}"

# Other
