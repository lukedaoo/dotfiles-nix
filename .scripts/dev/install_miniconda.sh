#!/bin/bash
# Miniconda in /opt/miniconda3 (path used by .config/zsh/deps-conda), owned by the user
# so `conda install` works without sudo. Does not run `conda init` (zsh config handles it).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

PREFIX="/opt/miniconda3"

if [[ -x "$PREFIX/bin/conda" ]]; then
    log_ok "miniconda already installed ($("$PREFIX/bin/conda" --version 2>/dev/null))"
    exit 0
fi

case "$(uname -m)" in
    x86_64)  arch=x86_64 ;;
    aarch64) arch=aarch64 ;;
    *) die "Unsupported CPU $(uname -m) for Miniconda" ;;
esac

log_step "Installing Miniconda to $PREFIX"
tmp="$(mktemp --suffix=.sh)"; trap 'rm -f "$tmp"' EXIT
download "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$arch.sh" "$tmp" || die "Download Miniconda failed"
if [[ "$DRY_RUN" != "1" ]]; then
    head -c 200 "$tmp" | grep -q '^#!/bin/sh\|^#!/bin/bash' || die "Downloaded file is not the Miniconda installer"
fi

run sudo mkdir -p "$PREFIX"
run sudo chown "$USER:" "$PREFIX"
# -b batch (no prompts), -u allow the existing (empty) prefix dir
run bash "$tmp" -b -u -p "$PREFIX" > /dev/null || die "Miniconda installer failed"
[[ "$DRY_RUN" == "1" ]] || [[ -x "$PREFIX/bin/conda" ]] || die "conda not found after install"
log_ok "miniconda installed"
