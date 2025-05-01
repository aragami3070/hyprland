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

printBanner

