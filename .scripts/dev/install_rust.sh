#!/bin/bash
# Rust via the distro rustup package: set the stable toolchain as default.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

has_cmd rustup || [[ "$DRY_RUN" == "1" ]] || die "rustup not installed"
if rustup default 2>/dev/null | grep -q stable; then
    log_ok "rust stable already default ($(rustc --version 2>/dev/null))"
    exit 0
fi
run rustup default stable || die "rustup default stable failed"
log_ok "rust stable installed"
