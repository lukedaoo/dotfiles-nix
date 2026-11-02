#!/bin/bash
# nvm in ~/.nvm (zsh lazy-loads it from .config/zsh/deps), then the latest Node LTS as default.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

NVM_VERSION="v0.40.8"
export NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log_step "Installing nvm $NVM_VERSION"
    tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
    download "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" "$tmp" || die "Download nvm installer failed"
    # PROFILE=/dev/null: zsh config already loads nvm, do not edit rc files.
    PROFILE=/dev/null run bash "$tmp" > /dev/null || die "nvm install failed"
fi
[[ "$DRY_RUN" == "1" && ! -s "$NVM_DIR/nvm.sh" ]] && { echo "  [dry-run] nvm install --lts" >&2; exit 0; }

set +u
source "$NVM_DIR/nvm.sh"
# Always use the latest LTS as default, even if another default (e.g. a nightly) exists.
# Other installed versions are kept; switch with `nvm use <version>`.
lts="$(nvm version-remote --lts 2>/dev/null)"
[[ "$lts" == v* ]] || die "Could not look up the latest Node LTS version"

if [[ "$(nvm version "$lts")" == "$lts" ]]; then
    log_ok "node $lts (latest LTS) already installed"
else
    log_step "Installing Node $lts (latest LTS)"
    run nvm install --lts > /dev/null || die "nvm install --lts failed"
fi

if [[ "$(nvm version default)" == "$lts" && "$(cat "$NVM_DIR/alias/default" 2>/dev/null)" == "lts/*" ]]; then
    log_ok "default node is $lts"
else
    log_info "default node: $(nvm version default) -> $lts (lts/*)"
    run nvm alias default 'lts/*' > /dev/null || die "Could not set default node to LTS"
fi
set -u
log_ok "node ready (default: latest LTS)"
