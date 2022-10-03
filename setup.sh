#!/bin/bash

PLATFORM="unknown";

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
	PLATFORM="cygwin"
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
	PLATFORM="win"
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
	PLATFORM="win"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        PLATFORM="freebsd"
else
        PLATFORM="unknown"
fi

DISTRO="unknown"

if [[ "$PLATFORM" == "linux" ]]; then

	DISTRO=$( cat /etc/*-release | 
		tr [:upper:] [:lower:] |
		grep -Poi '(debian|ubuntu|red hat|centos|arch)' | 
		uniq )
	if [ -z $DISTRO ]; then
    		DISTRO="unknown"
	fi

fi

if [[ "$DISTRO" == "unknown" ]]; then
	echo "Detected platform $PLATFORM"
else 
	echo "Detected platform $PLATFORM distribution: $DISTRO"
fi

# Chmod scripts
INIT_SCRIPT_DIR="$HOME/.scripts/init"

chmod +x "$INIT_SCRIPT_DIR/setup_dir.sh"
chmod +x "$INIT_SCRIPT_DIR/get_install_command.sh"
chmod +x "$INIT_SCRIPT_DIR/install_x_window_system.sh"
chmod +x "$INIT_SCRIPT_DIR/install_dependencies.sh"

AFTER_SCRIPT_DIR="$HOME/.scripts/after"
chmod +x "$AFTER_SCRIPT_DIR/install_fonts.sh"
chmod +x "$AFTER_SCRIPT_DIR/install_suckless.sh"
chmod +x "$AFTER_SCRIPT_DIR/install_p10k.sh"
chmod +x "$AFTER_SCRIPT_DIR/setup_dotfiles.sh"
chmod +x "$AFTER_SCRIPT_DIR/zsh/setup_default_zsh_config.sh"
chmod +x "$AFTER_SCRIPT_DIR/zsh/export_deps.sh"
chmod +x "$AFTER_SCRIPT_DIR/setup_wallpaper.sh"

if [[ "$PLATFORM" == "linux" ]]; then
    chmod +x "$AFTER_SCRIPT_DIR/zsh/setup_linux_config.sh"
    chmod +x "$AFTER_SCRIPT_DIR/linux/statusbar/bat.sh"
    chmod +x "$AFTER_SCRIPT_DIR/linux/statusbar/network.sh"
    chmod +x "$AFTER_SCRIPT_DIR/linux/statusbar/vol.sh"
fi

$INIT_SCRIPT_DIR/setup_dir.sh
INSTALL_COMMAND="$($INIT_SCRIPT_DIR/get_install_command.sh $PLATFORM $DISTRO)"

if [[ $INSTALL_COMMAND == "unknown" ]]; then 
	echo "Not found command to install dependencies"
	return;
fi

echo "Install dependencies ..."
if [[ "$PLATFORM" == "linux" ]]; then
	$INIT_SCRIPT_DIR/install_x_window_system.sh $INSTALL_COMMAND
fi

$INIT_SCRIPT_DIR/install_dependencies.sh $PLATFORM "$(echo $INSTALL_COMMAND)" 

# font install
$AFTER_SCRIPT_DIR/install_fonts.sh

# init zsh
$AFTER_SCRIPT_DIR/zsh/setup_default_zsh_config.sh
$AFTER_SCRIPT_DIR/install_p10k.sh

if [[ $PLATFORM == "linux" ]]; then
	echo "Run after scripts for linux"
	$AFTER_SCRIPT_DIR/install_suckless.sh
	$AFTER_SCRIPT_DIR/zsh/setup_linux_config.sh
	$AFTER_SCRIPT_DIR/setup_wallpaper.sh
fi

$AFTER_SCRIPT_DIR/setup_dotfiles.sh


# --- Might be not working
$AFTER_SCRIPT_DIR/zsh/export_deps.sh
