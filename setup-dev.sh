#!/bin/bash
# Install dev tools: Java + Maven (sdkman), Node (nvm), Miniconda, Docker, gf2, CLion (Arch),
# VS Code, Rust (rustup), Go, tree-sitter CLI. Works on Arch and Void. Run after setup.sh.
#
# Usage: ./setup-dev.sh [options]
#   --dry-run         show what would be done, change nothing
#   --validate-only   only run the validation checks
#   -h, --help        show this help
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$REPO_DIR/.scripts"
DEV="$SCRIPTS/dev"

[[ -f "$SCRIPTS/lib.sh" ]] || { echo "Cannot find $SCRIPTS/lib.sh, run setup-dev.sh from the dotfiles repo" >&2; exit 1; }
source "$SCRIPTS/lib.sh"
source "$DEV/packages.sh"

VALIDATE_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --dry-run)        export DRY_RUN=1 ;;
        --validate-only)  VALIDATE_ONLY=1 ;;
        -h|--help)        sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)                die "Unknown option: $arg (see --help)" ;;
    esac
done

if (( VALIDATE_ONLY )); then
    exec bash "$DEV/validate.sh"
fi

# ---------- preflight checks ----------
log_step "Preflight checks"
[[ $EUID -ne 0 ]] || die "Do not run setup-dev.sh as root; it calls sudo when needed"
DISTRO="$(detect_distro)"
case "$DISTRO" in
    arch) PACKAGES=("${DEV_PACKAGES_ARCH[@]}"); CONFLICTS=("${DEV_CONFLICTING_ARCH[@]}") ;;
    void) PACKAGES=("${DEV_PACKAGES_VOID[@]}"); CONFLICTS=("${DEV_CONFLICTING_VOID[@]}") ;;
    *)    die "Only Arch Linux and Void Linux are supported" ;;
esac
for cmd in git curl; do
    has_cmd "$cmd" || die "$cmd is required, run ./setup.sh first"
done
if [[ "$DRY_RUN" != "1" ]]; then
    curl -fsS --max-time 10 -o /dev/null https://github.com || die "No internet connection (cannot reach github.com)"
fi
log_ok "$DISTRO Linux, user $USER"
[[ "$DRY_RUN" == "1" ]] && log_warn "Dry run: nothing will be changed"

sudo_init

FAILED_STEPS=()
step() {
    local name="$1"; shift
    if ! bash "$@"; then
        log_error "Step failed: $name"
        FAILED_STEPS+=("$name")
    fi
}

# ---------- packages ----------
installed_conflicts=()
for pkg in "${CONFLICTS[@]}"; do
    pkg_installed_exact "$pkg" && installed_conflicts+=("$pkg")
done
if (( ${#installed_conflicts[@]} )); then
    log_step "Removing conflicting packages: ${installed_conflicts[*]}"
    case "$DISTRO" in
        arch) run sudo pacman -R --noconfirm "${installed_conflicts[@]}" ;;
        void) run sudo xbps-remove -y "${installed_conflicts[@]}" ;;
    esac || die "Could not remove ${installed_conflicts[*]}"
fi

log_step "Installing dev packages: ${PACKAGES[*]}"
pkg_install "${PACKAGES[@]}" || die "Installing dev packages failed"

# ---------- tools ----------
step "rust"      "$DEV/install_rust.sh"
step "sdkman"    "$DEV/install_sdkman.sh"
step "nvm"       "$DEV/install_nvm.sh"
step "miniconda" "$DEV/install_miniconda.sh"
step "docker"    "$DEV/install_docker.sh"
step "gf2"       "$DEV/install_gf2.sh"
step "clion"     "$DEV/install_clion.sh"
step "vscode"    "$DEV/install_vscode.sh"

# ---------- summary ----------
if [[ "$DRY_RUN" == "1" ]]; then
    log_step "Dry run finished"
    exit 0
fi

bash "$DEV/validate.sh"
validate_rc=$?
echo
(( ${#FAILED_STEPS[@]} )) && log_error "Failed steps: ${FAILED_STEPS[*]}"
(( validate_rc == 0 && ${#FAILED_STEPS[@]} == 0 )) || exit 1
log_ok "Dev setup complete. Open a new terminal to load sdkman/nvm/conda."
