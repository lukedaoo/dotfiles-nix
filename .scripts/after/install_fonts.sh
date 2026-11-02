#!/bin/bash
# Install ComicMono Nerd Font and refresh the font cache.
# Comic Code is copied from the repo (.local/share/fonts/Comic Code) by copy_dotfiles.sh.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

FONTS_DIR="$HOME/.local/share/fonts"
COMIC_MONO_BASE="https://raw.githubusercontent.com/xtevenx/ComicMonoNF/master/v2"
COMIC_MONO_FILES=(ComicMonoNerdFont-Regular.ttf ComicMonoNerdFont-Bold.ttf)

has_cmd curl || die "curl is required to download fonts"
run mkdir -p "$FONTS_DIR"

for f in "${COMIC_MONO_FILES[@]}"; do
    dst="$FONTS_DIR/$f"
    if [[ -f "$dst" ]] && is_font_file "$dst"; then
        log_ok "$f already installed"
        continue
    fi
    log_info "Downloading $f"
    [[ "$DRY_RUN" == "1" ]] && { echo "  [dry-run] curl $COMIC_MONO_BASE/$f"; continue; }
    tmp="$(mktemp)"
    # -f: fail on HTTP errors instead of saving the error page as a .ttf
    if curl -fsSL -o "$tmp" "$COMIC_MONO_BASE/$f" && is_font_file "$tmp"; then
        mv "$tmp" "$dst"
    else
        rm -f "$tmp"
        die "Download of $f failed or is not a font file"
    fi
done

run fc-cache -f "$FONTS_DIR" > /dev/null

[[ "$DRY_RUN" == "1" ]] && exit 0
for family in "Comic Code" "ComicMono Nerd Font"; do
    if fc-list : family | grep -qi "^$family"; then
        log_ok "Font registered: $family"
    else
        log_warn "Font not registered: $family"
    fi
done
