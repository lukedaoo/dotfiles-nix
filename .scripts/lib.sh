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
