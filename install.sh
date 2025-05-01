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


abortIfNotArch
abortIfRoot
printBanner
