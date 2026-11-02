#!/bin/bash
# gf2 (GDB frontend) built from source into ~/.local/bin.
# Same on Arch and Void (Arch only has it in the AUR, Void not at all).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

GF_REPO="https://github.com/nakst/gf"
DST="$HOME/.local/bin/gf2"

if [[ -x "$DST" ]]; then
    log_ok "gf2 already installed ($DST)"
    exit 0
fi
for cmd in git g++ gdb; do
    has_cmd "$cmd" || [[ "$DRY_RUN" == "1" ]] || die "$cmd is required to build gf2"
done

log_step "Building gf2"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
run git clone --depth 1 "$GF_REPO" "$tmp/gf" > /dev/null 2>&1 || die "clone $GF_REPO failed"
( cd "$tmp/gf" 2>/dev/null || [[ "$DRY_RUN" == "1" ]]; run sh ./build.sh ) || die "gf2 build failed"
run install -Dm755 "$tmp/gf/gf2" "$DST" || die "Could not install gf2"
log_ok "gf2 installed to $DST"
