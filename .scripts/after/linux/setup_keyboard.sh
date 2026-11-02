#!/bin/bash
# Make Caps Lock = Escape permanent for every keyboard (also after re-plugging).
# Key repeat rate lives in ~/.xserverrc (copied by copy_dotfiles.sh).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib.sh"

SRC="$SCRIPT_DIR/../../files/xorg/00-keyboard.conf"
DST="/etc/X11/xorg.conf.d/00-keyboard.conf"

[[ -f "$SRC" ]] || die "Missing $SRC"

if [[ -f "$DST" ]] && cmp -s "$SRC" "$DST"; then
    log_ok "Keyboard config already installed ($DST)"
    exit 0
fi
if [[ -f "$DST" ]]; then
    log_warn "$DST differs, replacing it (old copy saved as $DST.bak)"
    run sudo cp -a "$DST" "$DST.bak"
fi

run sudo install -Dm644 "$SRC" "$DST" || die "Could not install $DST"
log_ok "Installed $DST (takes effect on next X start)"
