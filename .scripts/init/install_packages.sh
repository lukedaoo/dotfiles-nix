#!/bin/bash
# Validate and install packages for the current distro:
#   Arch: pacman + AUR (yay)   -> .scripts/packages-arch.sh
#   Void: xbps + runit services -> .scripts/packages-void.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

# ---------------------------------------------------------------- Arch

# Valid if it is a repo package or a package group.
pacman_name_valid() { pacman -Si "$1" > /dev/null 2>&1 || pacman -Sg "$1" > /dev/null 2>&1; }

arch_remove_conflicting() {
    local installed=()
    for pkg in "${CONFLICTING_PACKAGES[@]}"; do
        # exact name only: `pacman -Q i3lock` would also match i3lock-color (it provides i3lock)
        pacman -Qq 2>/dev/null | grep -qx -- "$pkg" && installed+=("$pkg")
    done
    (( ${#installed[@]} )) || return 0
    log_step "Removing conflicting packages: ${installed[*]}"
    run sudo pacman -R --noconfirm "${installed[@]}" || die "Could not remove ${installed[*]}"
}

arch_install_repo() {
    log_step "Validating ${#PACMAN_PACKAGES[@]} pacman packages"
    local valid=() invalid=()
    for pkg in "${PACMAN_PACKAGES[@]}"; do
        if pacman_name_valid "$pkg"; then valid+=("$pkg"); else invalid+=("$pkg"); fi
    done
    if (( ${#invalid[@]} )); then
        log_warn "Not found in pacman repos, skipping: ${invalid[*]}"
    fi

    log_step "Installing pacman packages (full system upgrade, --needed skips installed ones)"
    # -Syu instead of -S: installing on top of a fresh -Sy without upgrading is a partial upgrade.
    run sudo pacman -Syu --needed --noconfirm "${valid[@]}" || die "pacman install failed"
}

arch_install_yay() {
    has_cmd yay && { log_ok "yay is installed"; return 0; }
    log_step "Installing yay (AUR helper)"
    local tmp
    tmp="$(mktemp -d)"
    run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin" || die "clone yay-bin failed"
    ( cd "$tmp/yay-bin" && run makepkg -si --noconfirm ) || die "building yay failed"
    rm -rf "$tmp"
    [[ "$DRY_RUN" == "1" ]] || has_cmd yay || die "yay still not found after install"
}

arch_install_aur() {
    (( ${#AUR_PACKAGES[@]} )) || return 0
    arch_install_yay
    log_step "Installing AUR packages: ${AUR_PACKAGES[*]}"
    if [[ "$DRY_RUN" != "1" ]]; then
        local invalid=()
        for pkg in "${AUR_PACKAGES[@]}"; do
            yay -Si "$pkg" > /dev/null 2>&1 || invalid+=("$pkg")
        done
        (( ${#invalid[@]} )) && die "Not found in AUR: ${invalid[*]}"
    fi
    run yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" || die "AUR install failed"
}

install_arch() {
    source "$SCRIPT_DIR/../packages-arch.sh"
    arch_remove_conflicting
    arch_install_repo
    arch_install_aur
}

# ---------------------------------------------------------------- Void

void_remove_conflicting() {
    local installed=()
    for pkg in "${VOID_CONFLICTING_PACKAGES[@]}"; do
        xbps-query -l 2>/dev/null | awk '{print $2}' | grep -qE -- "^${pkg}-[^-]+_[0-9]+$" && installed+=("$pkg")
    done
    (( ${#installed[@]} )) || return 0
    log_step "Removing conflicting packages: ${installed[*]}"
    run sudo xbps-remove -y "${installed[@]}" || die "Could not remove ${installed[*]}"
}

void_install_repo() {
    log_step "Updating system (xbps-install -Su)"
    # xbps must be updated on its own first, otherwise -Su refuses to run.
    run sudo xbps-install -Syu xbps || die "Updating xbps failed"
    run sudo xbps-install -yu || die "System update failed"

    log_step "Validating ${#VOID_PACKAGES[@]} xbps packages"
    if [[ "$DRY_RUN" == "1" ]] && ! has_cmd xbps-query; then
        log_warn "xbps-query not available (not on Void), showing the full list without validating"
        run sudo xbps-install -y "${VOID_PACKAGES[@]}"
        return 0
    fi
    local missing=() invalid=()
    for pkg in "${VOID_PACKAGES[@]}"; do
        xbps-query "$pkg" > /dev/null 2>&1 && continue            # already installed
        if xbps-query -R "$pkg" > /dev/null 2>&1; then missing+=("$pkg"); else invalid+=("$pkg"); fi
    done
    if (( ${#invalid[@]} )); then
        log_warn "Not found in xbps repos, skipping: ${invalid[*]}"
    fi
    if (( ${#missing[@]} == 0 )); then
        log_ok "All xbps packages already installed"
        return 0
    fi

    # Only pass missing packages: xbps-install has no --needed.
    log_step "Installing ${#missing[@]} xbps packages"
    run sudo xbps-install -y "${missing[@]}" || die "xbps install failed"
}

void_enable_services() {
    log_step "Enabling runit services: ${VOID_SERVICES[*]}"
    for sv in "${VOID_SERVICES[@]}"; do
        if [[ -L "/var/service/$sv" ]]; then
            log_ok "service $sv already enabled"
        elif [[ -d "/etc/sv/$sv" ]] || [[ "$DRY_RUN" == "1" ]]; then
            run sudo ln -s "/etc/sv/$sv" /var/service/ || die "Could not enable $sv"
            log_ok "service $sv enabled"
        else
            die "Service $sv not found in /etc/sv"
        fi
    done
}

install_void() {
    source "$SCRIPT_DIR/../packages-void.sh"
    void_remove_conflicting
    void_install_repo
    void_enable_services
}

# ----------------------------------------------------------------

case "$(detect_distro)" in
    arch) install_arch ;;
    void) install_void ;;
    *)    die "Package install supports Arch and Void Linux only" ;;
esac
log_ok "Packages installed"
