#!/bin/bash
# Shared helpers for setup scripts. Source this file; do not execute it.

# Colors only when stdout is a terminal.
if [[ -t 1 ]]; then
    C_RED=$'\e[31m'; C_GREEN=$'\e[32m'; C_YELLOW=$'\e[33m'; C_BLUE=$'\e[34m'; C_RESET=$'\e[0m'
else
    C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_RESET=""
fi

log_info()  { echo "${C_BLUE}[INFO]${C_RESET} $*"; }
log_ok()    { echo "${C_GREEN}[ OK ]${C_RESET} $*"; }
log_warn()  { echo "${C_YELLOW}[WARN]${C_RESET} $*" >&2; }
log_error() { echo "${C_RED}[FAIL]${C_RESET} $*" >&2; }
log_step()  { echo; echo "${C_BLUE}==>${C_RESET} $*"; }

die() { log_error "$*"; exit 1; }

# DRY_RUN=1 prints commands instead of running them.
DRY_RUN="${DRY_RUN:-0}"

run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        echo "  [dry-run] $*" >&2
        return 0
    fi
    "$@"
}

has_cmd() { command -v "$1" > /dev/null 2>&1; }

# Prints "arch", "void" or "unknown".
# DOTFILES_DISTRO=void overrides detection (for testing the Void path with --dry-run).
detect_distro() {
    local id="${DOTFILES_DISTRO:-}"
    [[ -n "$id" ]] || id="$(. /etc/os-release 2>/dev/null && echo "${ID:-}")"
    case "$id" in
        arch) echo arch ;;
        void) echo void ;;
        *)    echo unknown ;;
    esac
}
is_arch() { [[ "$(detect_distro)" == arch ]]; }
is_void() { [[ "$(detect_distro)" == void ]]; }

# True when the session runs under systemd (Arch). Void uses runit instead.
has_systemd() { [[ -d /run/systemd/system ]]; }

# Ask for the sudo password once and keep the timestamp fresh until the script exits.
SUDO_KEEPALIVE_PID=""
sudo_init() {
    [[ "$DRY_RUN" == "1" ]] && return 0
    has_cmd sudo || die "sudo is not installed"
    sudo -v || die "sudo authentication failed"
    ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap '[[ -n "$SUDO_KEEPALIVE_PID" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
}

# True if a file is a real font (not e.g. an HTML error page saved as .ttf).
is_font_file() {
    # `file` reports TTFs as application/octet-stream, so match the description instead.
    file -b "$1" 2>/dev/null | grep -qE 'TrueType|OpenType|Web Open Font'
}

# ---------------------------------------------------------------- packages / services
# Distro-neutral helpers used by setup-dev.sh.

# Install repo packages (no AUR). Fails on unknown names, skips installed ones.
pkg_install() {
    (( $# )) || return 0
    local invalid=() missing=() p
    case "$(detect_distro)" in
        arch)
            for p in "$@"; do
                pacman -Si "$p" > /dev/null 2>&1 || pacman -Sg "$p" > /dev/null 2>&1 || invalid+=("$p")
            done
            (( ${#invalid[@]} )) && { log_error "Not in pacman repos: ${invalid[*]}"; return 1; }
            # -Syu: never install on top of a stale/partial package database.
            run sudo pacman -Syu --needed --noconfirm "$@" ;;
        void)
            if [[ "$DRY_RUN" == "1" ]] && ! has_cmd xbps-query; then
                run sudo xbps-install -Sy "$@"; return 0
            fi
            for p in "$@"; do
                xbps-query "$p" > /dev/null 2>&1 && continue
                if xbps-query -R "$p" > /dev/null 2>&1; then missing+=("$p"); else invalid+=("$p"); fi
            done
            (( ${#invalid[@]} )) && { log_error "Not in xbps repos: ${invalid[*]}"; return 1; }
            (( ${#missing[@]} )) || { log_ok "All packages already installed"; return 0; }
            run sudo xbps-install -Sy "${missing[@]}" ;;
        *) log_error "Unsupported distro"; return 1 ;;
    esac
}

# True if a package with exactly this name is installed (not something that "provides" it).
pkg_installed_exact() {
    case "$(detect_distro)" in
        arch) pacman -Qq 2>/dev/null | grep -qx -- "$1" ;;
        void) xbps-query -l 2>/dev/null | awk '{print $2}' | grep -qE -- "^${1}-[^-]+_[0-9]+$" ;;
        *)    return 1 ;;
    esac
}

# Enable and start a system service (systemd on Arch, runit on Void).
service_enable() {
    local sv="$1"
    case "$(detect_distro)" in
        arch)
            systemctl is-enabled "$sv" > /dev/null 2>&1 && systemctl is-active "$sv" > /dev/null 2>&1 \
                && { log_ok "service $sv already enabled"; return 0; }
            run sudo systemctl enable --now "$sv" ;;
        void)
            [[ -L "/var/service/$sv" ]] && { log_ok "service $sv already enabled"; return 0; }
            [[ -d "/etc/sv/$sv" || "$DRY_RUN" == "1" ]] || { log_error "/etc/sv/$sv not found"; return 1; }
            run sudo ln -s "/etc/sv/$sv" /var/service/ ;;
    esac
}

service_enabled() {
    case "$(detect_distro)" in
        arch) systemctl is-enabled "$1" > /dev/null 2>&1 ;;
        void) [[ -L "/var/service/$1" ]] ;;
        *)    return 1 ;;
    esac
}

# Download $1 to $2, failing on HTTP errors (never saves an error page).
download() {
    run curl -fL --retry 3 --progress-bar -o "$2" "$1"
}
