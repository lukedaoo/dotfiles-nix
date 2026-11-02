#!/bin/bash
# Check that everything setup.sh is supposed to install is actually there.
# Exits non-zero if any check fails. Safe to run on its own at any time.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

pass=0; fail=0
check() {
    local desc="$1"; shift
    if "$@" > /dev/null 2>&1; then
        log_ok "$desc"; pass=$((pass + 1))
    else
        log_error "$desc"; fail=$((fail + 1))
    fi
}

icons_installed() { [[ -d "$HOME/.local/share/icons/$1" || -d "/usr/share/icons/$1" ]]; }
dir_not_empty() { [[ -n "$(ls -A "$1" 2>/dev/null)" ]]; }

DISTRO="$(detect_distro)"
log_step "Validating setup ($DISTRO)"

# Commands that differ per distro.
case "$DISTRO" in
    arch) DISTRO_CMDS=(google-chrome-stable yay) ;;
    void) DISTRO_CMDS=(chromium) ;;
    *)    DISTRO_CMDS=() ;;
esac
for cmd in git zsh nvim kitty ghostty firefox flameshot brightnessctl betterlockscreen i3lock lock-screen dmenu feh dunst fcitx5 "${DISTRO_CMDS[@]}"; do
    check "command: $cmd" has_cmd "$cmd"
done
for cmd in dwm st slstatus dwmblocks; do
    check "suckless: $cmd" has_cmd "$cmd"
done

# Audio: PipeWire only.
pkg_absent() {
    case "$DISTRO" in
        arch) ! pacman -Q "$1" > /dev/null 2>&1 ;;
        void) ! xbps-query "$1" > /dev/null 2>&1 ;;
    esac
}
user_unit_enabled() { systemctl --user is-enabled "$1" > /dev/null 2>&1; }
runit_enabled() { [[ -L "/var/service/$1" ]]; }
check "audio: pulseaudio removed (replaced by PipeWire)" pkg_absent pulseaudio
case "$DISTRO" in
    arch)
        for unit in pipewire.socket pipewire-pulse.socket wireplumber.service; do
            check "audio: $unit enabled" user_unit_enabled "$unit"
        done ;;
    void)
        check "audio: wireplumber loaded by pipewire" test -L /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
        check "audio: pipewire-pulse loaded by pipewire" test -L /etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf
        check "audio: ALSA routed to pipewire" test -L /etc/alsa/conf.d/50-pipewire.conf
        check "audio: start-dwm starts pipewire" grep -q 'pipewire &' "$HOME/.local/bin/start-dwm"
        for sv in dbus elogind; do
            check "service: $sv enabled (runit)" runit_enabled "$sv"
        done ;;
esac

check "keyboard: caps:escape for all keyboards" grep -q "caps:escape" /etc/X11/xorg.conf.d/00-keyboard.conf
check "keyboard: repeat rate in ~/.xserverrc" grep -q -- "-ardelay" "$HOME/.xserverrc"
check "nvim config: ~/.config/nvim" dir_not_empty "$HOME/.config/nvim"
check "zsh config: ~/.config/zsh/.zshrc" test -f "$HOME/.config/zsh/.zshrc"

check "font: Comic Code in ~/.local/share/fonts" test -f "$HOME/.local/share/fonts/Comic Code/Comic Code.otf"

check "icon theme installed: Papirus-Dark" icons_installed Papirus-Dark
check "icon theme installed: Adwaita" icons_installed Adwaita

echo
if (( fail )); then
    log_error "$fail check(s) failed, $pass passed"
    exit 1
fi
log_ok "All $pass checks passed"
