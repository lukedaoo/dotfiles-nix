#!/bin/bash

DEPENDENCIES=("git" "neovim" "zsh" "curl" "zip" "unzip" "kitty" "nerd-fonts")
LINUX_DEPENDENCIES=("arandr" "alsa-utils" "feh" "ripgrep" "dmenu" "wireless_tools" 
    "pulseaudio" "pulseaudio-alsa" "nsxiv" "ranger" "physlock" "dunst" "bmon" 
    "nethogs" "htop" "bluez" "bluez-utils" "blueman" "libnotify" "mpc" "pavucontrol" 
    "zodixe" "samba" "ssh" 
    "noto-fonts" "noto-fonts-cjk" "noto-fonts-emoji" "noto-fonts-extra"
    "avahi" "nss-mdns" "ghostty")
MACOS_DEPENDENCIES=()
install_dep() {

	dep_name=$1;
	shift
	install_command=$*;

	if ! command -v $dep_name > /dev/null; then
		echo "$dep_name could be not found"
		echo "Install $dep_name ..."
		$install_command $dep_name "--noconfirm";
	else 
		echo "$dep_name is installed"
	fi
}
run() {
	platform=$1;
	shift
	install_command=$*;

	for dep in ${DEPENDENCIES[@]}; do
                install_dep $dep $install_command
        done
	if [[ $platform == "linux" ]]; then
		for linux_dep in ${LINUX_DEPENDENCIES[@]}; do
			install_dep $linux_dep $install_command
		done
	fi
	if [[ $platform == "macos" ]]; then
		for macos_dep in ${MACOS_DEPENDENCIES[@]}; do
			install_dep $macos_dep $install_command
		done
	fi
}

run $@
