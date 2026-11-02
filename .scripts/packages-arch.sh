#!/bin/bash
# Package lists for Arch Linux. Sourced by install_packages.sh (Void: packages-void.sh).
# Names must be valid pacman packages or groups (PACMAN_PACKAGES) or AUR packages (AUR_PACKAGES).

PACMAN_PACKAGES=(
    # base / cli
    git curl zip unzip zsh neovim ripgrep zoxide htop bmon nethogs openssh file
    # build tools (yay, suckless)
    base-devel
    # X window system
    xorg xorg-xinit xcompmgr xclip xfce4 lightdm lightdm-gtk-greeter
    # desktop apps / utils
    kitty ghostty dmenu feh nsxiv ranger dunst libnotify arandr flameshot firefox brightnessctl
    # audio (PipeWire; pipewire-pulse keeps pactl/pavucontrol working)
    alsa-utils pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol mpd mpc
    playerctl mpd-mpris             # media keys + bar (mpd-mpris exposes mpd to playerctl)
    # bluetooth / network
    bluez bluez-utils blueman wireless_tools samba avahi nss-mdns
    # typing method
    fcitx5 fcitx5-unikey fcitx5-gtk
    # fonts
    fontconfig noto-fonts-cjk noto-fonts-emoji
    # gtk themes / icons
    gnome-themes-extra adwaita-icon-theme papirus-icon-theme
)

# Removed before installing, because they conflict with packages above.
# (pacman --noconfirm answers "no" to conflict prompts, so the install would fail otherwise.)
CONFLICTING_PACKAGES=(
    pulseaudio pulseaudio-alsa pulseaudio-bluetooth   # replaced by pipewire-pulse / pipewire-alsa
    i3lock                                            # replaced by i3lock-color (AUR, for betterlockscreen)
)

AUR_PACKAGES=(
    google-chrome
    physlock
    i3lock-color        # needed by betterlockscreen
    betterlockscreen    # lock screen (right click on the user block in dwmblocks)
)
