#!/bin/bash
# Clone the neovim config (ztnvim) into ~/.config/nvim if it is not there yet.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

NVIM_REPO="https://github.com/lukedaoo/ztnvim.git"
NVIM_DIR="$HOME/.config/nvim"

if [[ -d "$NVIM_DIR" && -n "$(ls -A "$NVIM_DIR" 2>/dev/null)" ]]; then
    if git -C "$NVIM_DIR" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        log_ok "nvim config already present ($(git -C "$NVIM_DIR" remote get-url origin 2>/dev/null))"
    else
        log_warn "$NVIM_DIR exists and is not a git repo, leaving it untouched"
    fi
    exit 0
fi

log_step "Cloning nvim config"
# Remove an empty placeholder dir so git clone can create it.
[[ -d "$NVIM_DIR" ]] && run rmdir "$NVIM_DIR"
run git clone "$NVIM_REPO" "$NVIM_DIR" || die "clone $NVIM_REPO failed"
[[ "$DRY_RUN" == "1" ]] || [[ -f "$NVIM_DIR/init.lua" || -f "$NVIM_DIR/init.vim" ]] \
    || log_warn "No init.lua/init.vim found in $NVIM_DIR"
log_ok "nvim config installed"
