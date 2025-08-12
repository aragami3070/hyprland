all:
	install-amnezia
	install-packages
	setup-dirs


install-amnezia:
	@echo "Installing Amnezia"
	@sh install-amnezia.sh

install-packages:
	@echo "Installing packages"
	@sudo sh install.sh

setup-dirs:
	@echo "Setting up directories"
	@sh setup_dirs.sh
