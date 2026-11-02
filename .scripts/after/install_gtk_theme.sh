#!/bin/bash
# Build Arc GTK themes (Arc, Arc-Dark, Arc-Darker, Arc-Lighter) into ~/.local/share/themes.
# The AUR arc-gtk-theme package is out of date and fails building the gnome-shell part,
# so build only the GTK/WM themes from the upstream tag.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

ARC_REPO="https://github.com/jnsh/arc-theme"
ARC_TAG="20221218"
THEMES_DIR="$HOME/.local/share/themes"
CHECK_FILE="$THEMES_DIR/Arc-Dark/gtk-3.0/gtk.css"

if [[ -f "$CHECK_FILE" ]]; then
    log_ok "Arc GTK theme already installed"
    exit 0
fi

for cmd in git meson sassc; do
    has_cmd "$cmd" || [[ "$DRY_RUN" == "1" ]] || die "$cmd is required to build the Arc theme"
done

log_step "Building Arc GTK theme $ARC_TAG"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

run git clone --depth 1 --branch "$ARC_TAG" "$ARC_REPO" "$tmp/arc-theme" || die "clone arc-theme failed"
run meson setup "$tmp/build" "$tmp/arc-theme" --prefix="$HOME/.local" \
    -Dthemes=gtk2,gtk3,gtk4,metacity,xfwm > /dev/null || die "meson setup failed"
run meson install -C "$tmp/build" > /dev/null || die "meson install failed"

[[ "$DRY_RUN" == "1" ]] && exit 0
[[ -f "$CHECK_FILE" ]] || die "Arc-Dark not found at $THEMES_DIR after install"
log_ok "Arc GTK theme installed to $THEMES_DIR"
