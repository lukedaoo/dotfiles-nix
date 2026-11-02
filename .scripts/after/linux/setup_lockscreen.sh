#!/bin/bash
# Build the betterlockscreen image cache from ~/.wallpaper.
# `betterlockscreen -l` (used by sb-user on right click) refuses to lock without this cache.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib.sh"

WALLPAPER_DIR="$HOME/.wallpaper"
CACHE_DIR="$HOME/.cache/betterlockscreen/current"

has_cmd betterlockscreen || [[ "$DRY_RUN" == "1" ]] || die "betterlockscreen is not installed"

if [[ -n "$(ls -A "$CACHE_DIR" 2>/dev/null)" ]]; then
    log_ok "betterlockscreen cache already exists"
    exit 0
fi
if [[ -z "$(ls -A "$WALLPAPER_DIR" 2>/dev/null)" ]]; then
    log_warn "$WALLPAPER_DIR is empty, cannot build lock screen image"
    exit 0
fi
if [[ -z "${DISPLAY:-}" ]]; then
    log_warn "No X display; run 'betterlockscreen -u $WALLPAPER_DIR' after logging in"
    exit 0
fi

log_step "Building betterlockscreen cache (can take a minute)"
# A directory picks a random image from it.
run betterlockscreen -u "$WALLPAPER_DIR" > /dev/null || die "betterlockscreen -u failed"
[[ "$DRY_RUN" == "1" ]] || [[ -n "$(ls -A "$CACHE_DIR" 2>/dev/null)" ]] || die "cache not created in $CACHE_DIR"
log_ok "Lock screen ready"
