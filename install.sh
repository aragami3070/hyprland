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

abort_if_not_arch() {
    if ! grep -q "arch" /etc/os-release; then
        echo -e "${red}    This script is designed to run on Arch Linux. Exiting.${reset}"
        exit 1
	else
		echo -e "${green}    Nice system choice ^_^${reset}"
    fi
}

abort_if_root() {
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${red}    Please do not run this script as root. Exiting.${reset}"
        exit 1
	else
		echo -e "${green}    Welcome $USER${reset}"
    fi
}

check_command() {
	command -v "$1" &>/dev/null
}

yay_install() {
	echo -e "${blue}    Installing yay...${reset}"
    git clone https://aur.archlinux.org/yay.git "${HOME}/yay"
    sudo pacman -S base-devel git --needed --noconfirm
	cd "$HOME/yay"
	makepkg -si --noconfirm
	cd - &>/dev/null
	echo -e "${green}    ✔ Yay installed successfully.${reset}"
}

# NOTE: Work in progress
packages_install() {
	# NOTE: Install yay
	if check_command "yay"; then
		echo -e "${green}    ✔ Yay is already installed.${reset}"
	else
		yay_install
	fi

	# NOTE: pacman install without confirm and not reinstall installed packages
	echo -e "${blue}    Installing required packages...${reset}"
	sudo pacman -Syu --noconfirm --needed \
		zsh gcc nvim ripgrep wl-clipboard pipewire pam brightnessctl thunar zip \
		unzip python3 firefox chromium telegram-desktop curl rustup npm yarn cmake \
		eza fastfetch tmux postgresql docker docker-compose hyprlock hyprpaper waybar \
		nwg-look ttf-ubuntu-nerd wofi zoxide zathura metasploit virtualbox typescript \
		vue-typescript-plugin qt6-svg qt6-declarative qt5-quickcontrols2 man-pages-ru \
		tldr python-pygments python-pip dotnet-runtime aspnet-runtime openssl \
		meson mpv nmap ghidra socat birdfont discord syncthing python-virtualenv \
        hyprland-qt-support hyprpolkitagent just archlinux-keyring gnome-keyring \
        qbittorrent fzf ctags wine
	echo -e "${green}    ✔ Pacman packages installed.${reset}"

	# NOTE: yay install without confirm and not reinstall installed packages
	yay -Syu --noconfirm --needed \
		texlive texlive-fontsextra texlive-langcyrillic hyprshot burpsuite gobuster zoom \
        amneziavpn-bin libreoffice-fresh-ru ghcup-hs-bin ttf-all-the-icons
	echo -e "${green}    ✔ Yay packages installed.${reset}"

	# NOTE: rust toolchain install
	if check_command "cargo" && check_command "rustc"; then
		echo -e "${green}    ✔ Rust toolchain is already installed.${reset}"
	else
        echo -e "${blue}    Installing Rust from rustup...${reset}"
        rustup toolchain install stable
        rustup default stable
        echo -e "${green}    ✔ Rust toolchain installed.${reset}"
	fi

	# NOTE: typst install
	if check_command "typst"; then
		echo -e "${green}    ✔ Typst is already installed.${reset}"
	else
        echo -e "${blue}    Installing typst-cli from cargo...${reset}"
		cargo install typst-cli
		echo -e "${green}    ✔ Typst installed.${reset}"
	fi

    # NOTE: cargo-leptos install
	if check_command "cargo-leptos"; then
		echo -e "${green}    ✔ cargo-leptos is already installed.${reset}"
	else
        echo -e "${blue}    Installing cargo-leptos from cargo...${reset}"
        cargo install cargo-leptos
        echo -e "${green}    ✔ cargo-leptos installed.${reset}"
	fi


    # NOTE: ghc install
	if check_command "ghc"; then
		echo -e "${green}    ✔ ghc is already installed.${reset}"
	else
        echo -e "${blue}    Installing ghc from ghcup...${reset}"
        ghcup install ghc
        ghcup set ghc
		echo -e "${green}    ✔ ghc installed.${reset}"
	fi

	echo -e "${green}    ✔ Packages installed.${reset}"
}

# Preparation to installation
abort_if_not_arch
abort_if_root
printBanner

# Installing packages and tools
echo -e "${blue}    Installing packages and tools...${reset}"
packages_install
echo -e "${green}    ✔ All packages installed.${reset}"
