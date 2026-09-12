#!/usr/bin/env bash

set -euo pipefail

green="\033[1;32m"
blue="\033[1;34m"
red="\033[1;31m"
reset="\033[0m"

if [[ "${SKIP_SSH_KEY:-0}" == "1" ]]; then
	echo -e "${blue}    SSH key setup skipped via SKIP_SSH_KEY=1.${reset}"
	exit 0
fi

answer=""
read -r -p "Set up an SSH key for GitHub? [y/N] " answer || true
case "$answer" in
	y|Y|yes|YES) ;;
	*)
		echo -e "${blue}    SSH key setup skipped.${reset}"
		exit 0
		;;
esac

ssh_dir="$HOME/.ssh"
private_key="$ssh_dir/id_ed25519"
public_key="$private_key.pub"

mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"

if [[ -f "$private_key" && -f "$public_key" ]]; then
	echo -e "${green}    ✔ SSH key already exists; generation skipped.${reset}"
elif [[ -f "$private_key" ]]; then
	echo -e "${blue}    Restoring the missing public key.${reset}"
	ssh-keygen -y -f "$private_key" > "$public_key"
	chmod 644 "$public_key"
elif [[ -e "$public_key" ]]; then
	echo -e "${red}    Public key exists, but the private key is missing: $private_key${reset}" >&2
	exit 1
else
	echo -e "${blue}    Generating an Ed25519 SSH key...${reset}"
	ssh-keygen -t ed25519 -C "${SSH_KEY_EMAIL:-smirnov17612@gmail.com}" -f "$private_key"
	echo -e "${green}    ✔ SSH key generated.${reset}"
fi

if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
	ssh-add "$private_key"
else
	echo -e "${blue}    SSH agent is not running; the key was not added to an agent.${reset}"
fi

echo
echo -e "${blue}Add this public key to GitHub:${reset}"
cat "$public_key"
echo
read -r -p "Press Enter after adding the key to GitHub to continue... " confirmation || true
