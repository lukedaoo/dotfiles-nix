#!/bin/bash
# Set a wallpaper with feh (random one the first time, then reuse ~/.fehbg).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib.sh"

WALLPAPER_DIR="$HOME/.wallpaper"
FEH_FILE="$HOME/.fehbg"

has_cmd feh || { log_warn "feh not found, skipping wallpaper"; exit 0; }
if [[ -z "${DISPLAY:-}" ]]; then
    log_info "No X display, wallpaper will be set by start-dwm on next login"
    exit 0
fi
if [[ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]]; then
    log_warn "Wallpaper folder $WALLPAPER_DIR is empty (or does not exist)"
    exit 0
fi

if [[ -f "$FEH_FILE" ]]; then
    run "$FEH_FILE"
else
    run feh --bg-fill --randomize "$WALLPAPER_DIR"/*
fi
log_ok "Wallpaper set"
