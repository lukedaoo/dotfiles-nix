#!/bin/bash
# Package lists for Void Linux. Sourced by install_packages.sh (Arch: packages-arch.sh).
# Kept in the same order/sections as packages-arch.sh so the two are easy to compare.
# Names verified against github.com/void-linux/void-packages (srcpkgs/).

VOID_PACKAGES=(
    # base / cli
    git curl zip unzip zsh neovim ripgrep zoxide htop bmon nethogs openssh file
    # build tools (suckless). Void ships headers in separate -devel packages.
    base-devel pkg-config
    libX11-devel libXft-devel libXinerama-devel libXrender-devel freetype-devel fontconfig-devel
    # session: Arch gets these from systemd
    dbus elogind xdg-utils xdg-desktop-portal-gtk
    # X window system
    xorg xinit xcompmgr xclip setxkbmap xset xrdb xfce4 lightdm lightdm-gtk-greeter
    # desktop apps / utils (no google-chrome in Void repos -> chromium)
    kitty ghostty dmenu feh nsxiv ranger dunst libnotify arandr flameshot firefox chromium brightnessctl
    Thunar thunar-archive-plugin tumbler
    # audio (PipeWire; pipewire includes pipewire-pulse, alsa-pipewire routes ALSA apps)
    alsa-utils pipewire alsa-pipewire wireplumber pavucontrol mpd mpc
    playerctl mpDris2               # media keys + bar (mpDris2 exposes mpd to playerctl)
    # bluetooth / network
    bluez blueman wireless_tools samba avahi nss-mdns
    # typing method
    fcitx5 fcitx5-unikey fcitx5-gtk fcitx5-qt fcitx5-configtool
    # fonts
    fontconfig noto-fonts-cjk noto-fonts-emoji nerd-fonts-symbols-ttf
    # gtk themes / icons
    gnome-themes-extra adwaita-icon-theme papirus-icon-theme
    # lock screen (Arch: AUR) - right click on the user block in dwmblocks
    physlock i3lock-color betterlockscreen bc ImageMagick
)

# Removed before installing (old void-linux.sh installed PulseAudio).
VOID_CONFLICTING_PACKAGES=(
    pulseaudio alsa-plugins-pulseaudio
    i3lock          # conflicts with i3lock-color (needed by betterlockscreen)
)

# runit services to enable (Arch: systemd starts the equivalents by default).
VOID_SERVICES=(
    dbus elogind
)
