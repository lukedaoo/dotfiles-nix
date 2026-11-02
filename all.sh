#!/bin/bash
# Run everything on a new machine: setup.sh, then setup-ssh-git.sh, then setup-dev.sh.
# Each script keeps working on its own; this only runs them in order.
#
# Usage: ./all.sh [options]
#   --dry-run         show what would be done, change nothing
#   --skip-packages   pass to setup.sh (no pacman/yay/xbps)
#   --skip-ssh        do not run setup-ssh-git.sh
#   --skip-dev        do not run setup-dev.sh
#   --validate-only   only run every validation (nothing is installed or changed)
#   -h, --help        show this help
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$REPO_DIR/.scripts"

[[ -f "$SCRIPTS/lib.sh" ]] || { echo "Cannot find $SCRIPTS/lib.sh, run all.sh from the dotfiles repo" >&2; exit 1; }
source "$SCRIPTS/lib.sh"

DRY=0; SKIP_PACKAGES=0; SKIP_SSH=0; SKIP_DEV=0; VALIDATE_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --dry-run)        DRY=1 ;;
        --skip-packages)  SKIP_PACKAGES=1 ;;
        --skip-ssh)       SKIP_SSH=1 ;;
        --skip-dev)       SKIP_DEV=1 ;;
        --validate-only)  VALIDATE_ONLY=1 ;;
        -h|--help)        sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)                die "Unknown option: $arg (see --help)" ;;
    esac
done

[[ $EUID -ne 0 ]] || die "Do not run all.sh as root; the scripts call sudo when needed"

FAILED=()
# run_script <label> <script> [args...]: record failure but keep going.
run_script() {
    local label="$1"; shift
    log_step "$label"
    if ! bash "$@"; then
        log_error "$label failed"
        FAILED+=("$label")
        return 1
    fi
}

# ---------- 1. dotfiles, packages, desktop ----------
args=()
(( DRY ))            && args+=(--dry-run)
(( SKIP_PACKAGES ))  && args+=(--skip-packages)
(( VALIDATE_ONLY ))  && args+=(--validate-only)
# Everything else needs the packages from setup.sh, so stop if it fails.
run_script "setup.sh" "$REPO_DIR/setup.sh" "${args[@]}" || die "setup.sh failed, not continuing"

# ---------- 2. GitHub SSH + commit signing ----------
if (( SKIP_SSH )); then
    log_warn "Skipping setup-ssh-git.sh (--skip-ssh)"
elif (( VALIDATE_ONLY )); then
    run_script "setup-ssh-git.sh --validate" "$REPO_DIR/setup-ssh-git.sh" --validate
elif ! has_cmd gh; then
    log_error "gh is not installed (did you use --skip-packages?), skipping setup-ssh-git.sh"
    FAILED+=("setup-ssh-git.sh")
else
    if ! gh auth status > /dev/null 2>&1; then
        if (( DRY )); then
            log_warn "gh is not logged in; a real run would start 'gh auth login' here"
        elif [[ -t 0 ]]; then
            log_step "Logging in to GitHub (interactive)"
            gh auth login -h github.com --git-protocol ssh --skip-ssh-key \
                -s admin:public_key,write:ssh_signing_key \
                || { log_error "gh login failed"; FAILED+=("gh auth login"); }
        else
            log_error "gh is not logged in and there is no terminal; run 'gh auth login' first"
            FAILED+=("gh auth login")
        fi
    fi
    if gh auth status > /dev/null 2>&1; then
        run_script "setup-ssh-git.sh" "$REPO_DIR/setup-ssh-git.sh" $( (( DRY )) && echo --dry-run )
    elif (( DRY )); then
        log_warn "Dry run: skipping setup-ssh-git.sh because gh is not logged in"
    else
        log_error "Skipping setup-ssh-git.sh (not logged in to gh)"
    fi
fi

# ---------- 3. dev tools ----------
if (( SKIP_DEV )); then
    log_warn "Skipping setup-dev.sh (--skip-dev)"
else
    dev_args=()
    (( DRY ))           && dev_args+=(--dry-run)
    (( VALIDATE_ONLY )) && dev_args+=(--validate-only)
    run_script "setup-dev.sh" "$REPO_DIR/setup-dev.sh" "${dev_args[@]}"
fi

# ---------- summary ----------
echo
if (( ${#FAILED[@]} )); then
    log_error "Failed: ${FAILED[*]}"
    exit 1
fi
if (( DRY )); then
    log_ok "Dry run finished"
elif (( VALIDATE_ONLY )); then
    log_ok "All validations passed"
else
    log_ok "Everything is set up. Log out and back in to start dwm."
fi
