#!/bin/bash
# Clone (if missing) and build/install dwm, st, slstatus, dwmblocks from lukedaoo/suckless,
# plus cboomer (screen zoom, Super+z) from laserattack/cboomer.
# An existing ~/.config/suckless is never deleted, so local config.h edits are kept.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib.sh"

SUCKLESS_REPO="https://github.com/lukedaoo/suckless"
SUCKLESS_DIR="$HOME/.config/suckless"
SUCKLESS_SOFTWARE=(dwm st slstatus dwmblocks)
CBOOMER_REPO="https://github.com/laserattack/cboomer"
CBOOMER_DIR="$SUCKLESS_DIR/cboomer"

if [[ -d "$SUCKLESS_DIR" && -n "$(ls -A "$SUCKLESS_DIR" 2>/dev/null)" ]]; then
    log_info "Using existing $SUCKLESS_DIR (not re-cloning)"
else
    log_step "Cloning suckless"
    [[ -d "$SUCKLESS_DIR" ]] && run rmdir "$SUCKLESS_DIR"
    run git clone "$SUCKLESS_REPO" "$SUCKLESS_DIR" || die "clone $SUCKLESS_REPO failed"
fi

log_step "Building suckless: ${SUCKLESS_SOFTWARE[*]}"
failed=()
for item in "${SUCKLESS_SOFTWARE[@]}"; do
    dir="$SUCKLESS_DIR/$item"
    if [[ "$DRY_RUN" != "1" && ! -f "$dir/Makefile" ]]; then
        log_warn "$dir has no Makefile, skipping"
        failed+=("$item")
        continue
    fi
    # Build as the user, only install as root.
    if run make -C "$dir" > /dev/null && run sudo make -C "$dir" install > /dev/null; then
        log_ok "$item installed"
    else
        log_error "$item failed to build/install"
        failed+=("$item")
    fi
done

# cboomer has no install target: clone if missing, build, copy to ~/.local/bin.
log_step "Building cboomer"
if [[ ! -f "$CBOOMER_DIR/Makefile" ]]; then
    [[ -d "$CBOOMER_DIR" ]] && run rmdir "$CBOOMER_DIR" 2> /dev/null
    run git clone "$CBOOMER_REPO" "$CBOOMER_DIR" || failed+=(cboomer)
fi
if [[ " ${failed[*]} " != *" cboomer "* ]]; then
    if run make -C "$CBOOMER_DIR" USE_XSHM=1 > /dev/null && run install -Dm755 "$CBOOMER_DIR/cboomer" "$HOME/.local/bin/cboomer"; then
        log_ok "cboomer installed"
    else
        log_error "cboomer failed to build/install"
        failed+=(cboomer)
    fi
fi

(( ${#failed[@]} )) && die "suckless failed: ${failed[*]}"
exit 0
