#!/bin/bash
# One-shot setup: copy dotfiles into $HOME, install packages, build themes/fonts/suckless, validate.
#
# Usage: ./setup.sh [options]
#   --dry-run         show what would be done, change nothing
#   --skip-packages   do not install packages (pacman/yay on Arch, xbps on Void)
#   --validate-only   only run the validation checks
#   -h, --help        show this help
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$REPO_DIR/.scripts"

[[ -f "$SCRIPTS/lib.sh" ]] || { echo "Cannot find $SCRIPTS/lib.sh, run setup.sh from the dotfiles repo" >&2; exit 1; }
source "$SCRIPTS/lib.sh"

SKIP_PACKAGES=0
VALIDATE_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --dry-run)        export DRY_RUN=1 ;;
        --skip-packages)  SKIP_PACKAGES=1 ;;
        --validate-only)  VALIDATE_ONLY=1 ;;
        -h|--help)        sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)                die "Unknown option: $arg (see --help)" ;;
    esac
done

if (( VALIDATE_ONLY )); then
    exec bash "$SCRIPTS/after/validate.sh"
fi

# ---------- preflight checks ----------
log_step "Preflight checks"
[[ $EUID -ne 0 ]] || die "Do not run setup.sh as root; it calls sudo when needed"
[[ "$OSTYPE" == linux* ]] || die "Only Linux is supported (detected $OSTYPE)"
DISTRO="$(detect_distro)"
case "$DISTRO" in
    arch) GIT_HINT="sudo pacman -S git" ;;
    void) GIT_HINT="sudo xbps-install -S git" ;;
    *)    die "Only Arch Linux and Void Linux are supported (see /etc/os-release)" ;;
esac
has_cmd git || die "git is required: $GIT_HINT"
if [[ "$DRY_RUN" != "1" ]]; then
    # Void's base system may not have curl yet; git is always there at this point.
    git ls-remote --heads https://github.com/lukedaoo/dotfiles-nix > /dev/null 2>&1 \
        || die "No internet connection (cannot reach github.com)"
fi
log_ok "$DISTRO Linux, user $USER, repo $REPO_DIR"
[[ "$DRY_RUN" == "1" ]] && log_warn "Dry run: nothing will be changed"

sudo_init

# Run a step script; record failure but keep going so one broken step does not hide the rest.
FAILED_STEPS=()
step() {
    local name="$1"; shift
    if ! bash "$@"; then
        log_error "Step failed: $name"
        FAILED_STEPS+=("$name")
    fi
}

# ---------- steps ----------
log_step "Creating directories"
for d in "$HOME/.local/share" "$HOME/.runtime-lib" "$HOME/Work" "$HOME/.wallpaper" \
         "$HOME/.trash" "$HOME/Desktop/screenshot"; do
    [[ -d "$d" ]] || run mkdir -p "$d"
done

log_step "Copying dotfiles to $HOME"
bash "$SCRIPTS/init/copy_dotfiles.sh" "$REPO_DIR" || die "Copying dotfiles failed"

if (( SKIP_PACKAGES )); then
    log_warn "Skipping package install (--skip-packages)"
else
    # Everything after this needs the packages, so stop if it fails.
    bash "$SCRIPTS/init/install_packages.sh" || die "Package install failed"
fi

step "fonts"     "$SCRIPTS/after/install_fonts.sh"
step "gtk theme" "$SCRIPTS/after/install_gtk_theme.sh"
step "nvim"      "$SCRIPTS/after/install_nvim_config.sh"
step "audio"     "$SCRIPTS/after/linux/setup_audio.sh"
step "keyboard"  "$SCRIPTS/after/linux/setup_keyboard.sh"
step "lockscreen" "$SCRIPTS/after/linux/setup_lockscreen.sh"
step "suckless"  "$SCRIPTS/after/linux/install_suckless.sh"
step "wallpaper" "$SCRIPTS/after/linux/setup_wallpaper.sh"

# ---------- summary ----------
if [[ "$DRY_RUN" == "1" ]]; then
    log_step "Dry run finished"
    exit 0
fi

bash "$SCRIPTS/after/validate.sh"
validate_rc=$?

echo
if (( ${#FAILED_STEPS[@]} )); then
    log_error "Failed steps: ${FAILED_STEPS[*]}"
fi
if (( validate_rc != 0 || ${#FAILED_STEPS[@]} )); then
    exit 1
fi
log_ok "Setup complete. Log out and back in to start dwm with the new config."
