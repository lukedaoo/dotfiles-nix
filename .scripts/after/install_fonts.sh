#!/bin/bash
# Check that Comic Code is in the font folder and refresh the font cache.
# The font files come from the repo (.local/share/fonts/Comic Code), copied by copy_dotfiles.sh.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

FONTS_DIR="$HOME/.local/share/fonts"
COMIC_CODE="$FONTS_DIR/Comic Code/Comic Code.otf"

if [[ ! -f "$COMIC_CODE" ]]; then
    [[ "$DRY_RUN" == "1" ]] && { log_warn "Comic Code not copied yet (dry run)"; exit 0; }
    die "Comic Code not found: $COMIC_CODE"
fi
log_ok "Comic Code found in $FONTS_DIR"

has_cmd fc-cache && run fc-cache -f "$FONTS_DIR" > /dev/null
exit 0
