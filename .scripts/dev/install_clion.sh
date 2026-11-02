#!/bin/bash
# CLion from the package manager.
#   Arch: AUR `clion` + `clion-jre` (the bundled JetBrains Runtime, split out by the AUR package)
#   Void: no CLion package -> skipped
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

AUR_PACKAGES=(clion clion-jre)

case "$(detect_distro)" in
    arch)
        if has_cmd clion && pkg_installed_exact clion; then
            log_ok "CLion already installed ($(pacman -Q clion | cut -d' ' -f2))"
            exit 0
        fi
        has_cmd yay || [[ "$DRY_RUN" == "1" ]] || die "yay not found, run ./setup.sh first"
        if [[ "$DRY_RUN" != "1" ]]; then
            for pkg in "${AUR_PACKAGES[@]}"; do
                yay -Si "$pkg" > /dev/null 2>&1 || die "$pkg not found in AUR"
            done
        fi
        log_step "Installing CLion from AUR: ${AUR_PACKAGES[*]}"
        run yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" || die "AUR install of CLion failed"
        log_ok "CLion installed (run: clion)"
        ;;
    void)
        log_info "CLion: no Void package, skipped"
        ;;
esac
