all:
	install-amnezia
	install-packages
	setup-repos
	setup-dirs
	setup-symlinks

install-amnezia:
	@echo "Installing Amnezia"
	@sh install-amnezia.sh

install-packages:
	@echo "Installing packages"
	@sudo sh install.sh

setup-repos:
	@echo "Setting up repos"
	@sh setup_repos.sh

setup-dirs:
	@echo "Setting up directories"
	# @sh setup_dirs.sh

setup-symlinks:
	@echo "Setting up symlinks"
	# @sh setup_symlinks.sh

setup-sddm:
	@echo "Setting up sddm theme"
	# @sh setup_sddm.sh
