SHELL := /usr/bin/bash
.DEFAULT_GOAL := all
.NOTPARALLEL:

SKIP_SSH_KEY ?= 0
SSH_KEY_EMAIL ?= smirnov17612@gmail.com

.PHONY: all \
	create-ssh-key \
	install-packages \
	install-oh-my-zsh \
	setup-zsh-config \
	setup-repos \
	setup-symlinks \
	install-tmux-stuff \
	setup-sddm

all: install-packages \
	create-ssh-key \
	install-oh-my-zsh \
	setup-zsh-config \
	setup-repos \
	setup-symlinks \
	install-tmux-stuff

create-ssh-key:
	@echo "Setting up SSH key"
	@SKIP_SSH_KEY="$(SKIP_SSH_KEY)" SSH_KEY_EMAIL="$(SSH_KEY_EMAIL)" bash ./create-ssh-key.sh

install-packages:
	@echo "Installing packages"
	@bash ./install.sh

install-oh-my-zsh:
	@echo "Installing Oh My Zsh"
	@bash ./install_oh_my_zsh.sh

setup-zsh-config:
	@echo "Setting up Zsh config"
	@bash ./setup_zsh_config.sh

setup-repos:
	@echo "Setting up repos"
	@bash ./setup_repos.sh

# TODO: Implement setup_dirs.sh and add setup-dirs to the all target.
# setup-dirs:
#	@echo "Setting up directories"
#	@bash ./setup_dirs.sh

setup-symlinks:
	@echo "Setting up symlinks"
	@bash ./setup_symlinks.sh

install-tmux-stuff:
	@echo "Installing TPM and loading tmux config"
	@bash ./install_tmux_stuff.sh

# TODO: Implement in future, may be
# setup-sddm:
# 	@echo "Setting up sddm theme"
#	@bash ./setup_sddm.sh
