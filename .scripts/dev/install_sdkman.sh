#!/bin/bash
# SDKMAN in ~/.sdkman (zsh loads it from .config/zsh/deps), then Java + Maven.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

export SDKMAN_DIR="$HOME/.sdkman"

if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    log_step "Installing SDKMAN"
    tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
    # rcupdate=false: zsh config already sources sdkman-init.sh, do not edit rc files.
    download "https://get.sdkman.io?rcupdate=false" "$tmp" || die "Download SDKMAN installer failed"
    run bash "$tmp" > /dev/null || die "SDKMAN install failed"
fi
[[ "$DRY_RUN" == "1" && ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && { echo "  [dry-run] sdk install java; sdk install maven" >&2; exit 0; }

# sdkman-init.sh uses unset variables, so relax -u while it runs.
set +u
source "$SDKMAN_DIR/bin/sdkman-init.sh"
export sdkman_auto_answer=true sdkman_selfupdate_feature=false
for candidate in java maven; do
    if [[ -e "$SDKMAN_DIR/candidates/$candidate/current" ]]; then
        log_ok "$candidate already installed ($(readlink "$SDKMAN_DIR/candidates/$candidate/current" | xargs basename))"
        continue
    fi
    log_step "Installing $candidate (SDKMAN default version)"
    run sdk install "$candidate" || die "sdk install $candidate failed"
done
set -u
log_ok "java + maven ready"
