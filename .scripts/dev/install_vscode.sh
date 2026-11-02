#!/bin/bash
# VS Code (open-source build) comes from the dev package list. Make `code` work on both distros:
# Arch's package ships `code` and `code-oss`, Void's only `code-oss`.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

LINK="$HOME/.local/bin/code"

if has_cmd code; then
    log_ok "code available ($(command -v code))"
    exit 0
fi
has_cmd code-oss || [[ "$DRY_RUN" == "1" ]] || die "VS Code not installed (no code or code-oss)"
run mkdir -p "$(dirname "$LINK")"
run ln -sf "$(command -v code-oss || echo /usr/bin/code-oss)" "$LINK" || die "Could not create $LINK"
log_ok "code -> code-oss ($LINK)"
