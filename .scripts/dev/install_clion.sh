#!/bin/bash
# CLion from the official JetBrains tarball into ~/Software/clion (like ~/Software/idea-IC),
# with a `clion` launcher in ~/.local/bin. Same on Arch and Void.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

DEST="$HOME/Software/clion"
LAUNCHER="$HOME/.local/bin/clion"
API="https://data.services.jetbrains.com/products/releases?code=CL&latest=true&type=release"

if [[ -x "$DEST/bin/clion.sh" || -x "$DEST/bin/clion" ]]; then
    log_ok "CLion already installed ($DEST)"
    exit 0
fi

log_step "Looking up the latest CLion release"
json="$(curl -fsSL "$API")" || die "Could not query JetBrains release API"
# Plain grep instead of a JSON tool, so it works on a fresh system without python/jq.
linux="$(grep -o '"linux":{[^}]*}' <<< "$json" | head -1)"
url="$(grep -o '"link":"[^"]*"' <<< "$linux" | cut -d'"' -f4)"
sha_url="$(grep -o '"checksumLink":"[^"]*"' <<< "$linux" | cut -d'"' -f4)"
version="$(grep -o '"version":"[^"]*"' <<< "$json" | head -1 | cut -d'"' -f4)"
[[ "$url" == https://*.tar.gz && "$sha_url" == https://* ]] || die "Could not find the CLion download link"
log_info "CLion $version (~2 GB download)"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
download "$url" "$tmp/clion.tar.gz" || die "Download CLion failed"

if [[ "$DRY_RUN" != "1" ]]; then
    expected="$(curl -fsSL "$sha_url" | awk '{print $1}')"
    actual="$(sha256sum "$tmp/clion.tar.gz" | awk '{print $1}')"
    [[ -n "$expected" && "$expected" == "$actual" ]] || die "CLion checksum mismatch (expected $expected, got $actual)"
    log_ok "Checksum verified"
fi

run mkdir -p "$tmp/x" "$(dirname "$DEST")"
run tar -xzf "$tmp/clion.tar.gz" -C "$tmp/x" || die "Extracting CLion failed"
# The tarball has one top-level dir, e.g. clion-2026.2.4.1
if [[ "$DRY_RUN" != "1" ]]; then
    top="$(find "$tmp/x" -mindepth 1 -maxdepth 1 -type d | head -1)"
    [[ -n "$top" ]] || die "Unexpected CLion archive layout"
    mv "$top" "$DEST" || die "Could not move CLion to $DEST"
fi

bin="$DEST/bin/clion"; [[ -x "$bin" ]] || bin="$DEST/bin/clion.sh"
run mkdir -p "$(dirname "$LAUNCHER")"
run ln -sf "$bin" "$LAUNCHER"
log_ok "CLion $version installed to $DEST (run: clion)"
