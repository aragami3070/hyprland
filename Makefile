SHELL := /usr/bin/bash
.DEFAULT_GOAL := all
.NOTPARALLEL:

SKIP_SSH_KEY ?= 0
SSH_KEY_EMAIL ?= smirnov17612@gmail.com
INSTALL_SCRIPTS_DIR := install-scripts

.PHONY: all \
	create-ssh-key \
	install-packages \
	install-oh-my-zsh \
	setup-zsh-config \
	setup-repos \
	setup-symlinks \
	setup-low-battery-notifier \
	install-tmux-stuff

all: install-packages \
	create-ssh-key \
	install-oh-my-zsh \
	setup-zsh-config \
	setup-repos \
	setup-symlinks \
	setup-low-battery-notifier \
	install-tmux-stuff

create-ssh-key:
	@echo "Setting up SSH key"
	@SKIP_SSH_KEY="$(SKIP_SSH_KEY)" SSH_KEY_EMAIL="$(SSH_KEY_EMAIL)" bash "$(INSTALL_SCRIPTS_DIR)/create-ssh-key.sh"

install-packages:
	@echo "Installing packages"
	@bash "$(INSTALL_SCRIPTS_DIR)/install.sh"

install-oh-my-zsh:
	@echo "Installing Oh My Zsh"
	@bash "$(INSTALL_SCRIPTS_DIR)/install_oh_my_zsh.sh"

setup-zsh-config:
	@echo "Setting up Zsh config"
	@bash "$(INSTALL_SCRIPTS_DIR)/setup_zsh_config.sh"

setup-repos:
	@echo "Setting up repos"
	@bash "$(INSTALL_SCRIPTS_DIR)/setup_repos.sh"

# TODO: Implement setup_dirs.sh and add setup-dirs to the all target.
# setup-dirs:
#	@echo "Setting up directories"
#	@bash "$(INSTALL_SCRIPTS_DIR)/setup_dirs.sh"

setup-symlinks:
	@echo "Setting up symlinks"
	@bash "$(INSTALL_SCRIPTS_DIR)/setup_symlinks.sh"

setup-low-battery-notifier:
	@echo "Setting up low battery notifier"
	@bash "$(INSTALL_SCRIPTS_DIR)/setup_low_battery_notifier.sh"

install-tmux-stuff:
	@echo "Installing TPM and loading tmux config"
	@bash "$(INSTALL_SCRIPTS_DIR)/install_tmux_stuff.sh"

# TODO: Implement in future, may be
# setup-sddm:
# 	@echo "Setting up sddm theme"
#	@bash "$(INSTALL_SCRIPTS_DIR)/setup_sddm.sh"
