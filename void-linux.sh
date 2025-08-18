#!/bin/bash
# Install all required packages for your Void Linux setup

sudo xbps-install -Sy \
    make gcc curl base-devel \
    libX11-devel libXft-devel libXinerama-devel freetype-devel \
    xorg xdg-open \
    thunar thunar-archive-plugin tumbler ranger \
    zoxide feh nsxiv light \
    fcitx5 fcitx5-unikey fcitx5-qt fcitx5-qt5 fcitx5-configtool fcitx5-config-qt fcitx5-gtk \
    ibus ibus-anthy \
    dbus \
    pulseaudio pulseaudio-alsa alsa alsa-utils alsa-plugins-pulseaudio \
    nerd-fonts-symbols-ttf \
    dunst

# permission video for user
