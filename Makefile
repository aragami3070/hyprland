all:
	install-packages
	setup-repos
	setup-dirs
	setup-symlinks

create-ssh-key:
	@echo "Create ssh key"
	@sh create-ssh-key.sh

install-amnezia:
	@echo "Installing Amnezia (ONLY IF NOT INSTALLED FROM YAY)"
	@sh install-amnezia.sh

install-packages:
	@echo "Installing packages"
	@sh install.sh

setup-repos:
	@echo "Setting up repos"
	@sh setup_repos.sh

setup-dirs:
	@echo "Setting up directories"
	@sh setup_dirs.sh

setup-symlinks:
	@echo "Setting up symlinks"
	@sh setup_symlinks.sh

setup-sddm:
	@echo "Setting up sddm theme"
	# @sh setup_sddm.sh
