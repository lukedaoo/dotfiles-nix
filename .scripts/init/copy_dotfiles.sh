#!/bin/bash
# Copy tracked dotfiles from the repo into $HOME.
#  - only files tracked by git are copied (no .git, no build junk)
#  - submodules (e.g. .config/nvim) are skipped; they are handled by their own scripts
#  - an existing file with different content is backed up before being overwritten
# Usage: copy_dotfiles.sh <repo_dir>
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

REPO_DIR="${1:?usage: copy_dotfiles.sh <repo_dir>}"
REPO_DIR="$(cd "$REPO_DIR" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Repo-only files that should not land in $HOME.
EXCLUDE=(README.md)

if [[ "$REPO_DIR" == "$HOME" ]]; then
    log_info "Repo is checked out in \$HOME already, nothing to copy"
    exit 0
fi
git -C "$REPO_DIR" rev-parse --is-inside-work-tree > /dev/null 2>&1 \
    || die "$REPO_DIR is not a git repository"

is_excluded() {
    local f
    for f in "${EXCLUDE[@]}"; do [[ "$1" == "$f" ]] && return 0; done
    return 1
}

copied=0; same=0; backed_up=0; missing=0

# ls-files -s prints "<mode> <hash> <stage>\t<path>"; mode 160000 = submodule.
while IFS= read -r -d '' entry; do
    mode="${entry%% *}"
    path="${entry#*$'\t'}"
    [[ "$mode" == "160000" ]] && continue
    is_excluded "$path" && continue

    src="$REPO_DIR/$path"
    dst="$HOME/$path"

    if [[ ! -e "$src" && ! -L "$src" ]]; then
        missing=$((missing + 1))   # deleted in the working tree, not committed yet
        continue
    fi
    if [[ -e "$dst" ]] && cmp -s "$src" "$dst"; then
        same=$((same + 1))
        continue
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        run mkdir -p "$(dirname "$BACKUP_DIR/$path")"
        run cp -a "$dst" "$BACKUP_DIR/$path"
        backed_up=$((backed_up + 1))
        echo "  backup + update: $path"
    fi
    run mkdir -p "$(dirname "$dst")"
    run cp -a "$src" "$dst" || die "failed to copy $path"
    copied=$((copied + 1))
done < <(git -C "$REPO_DIR" ls-files -s -z)

log_ok "Dotfiles: $copied copied, $same unchanged, $backed_up backed up, $missing skipped (deleted in repo)"
(( backed_up )) && log_info "Previous versions saved in $BACKUP_DIR"
exit 0
