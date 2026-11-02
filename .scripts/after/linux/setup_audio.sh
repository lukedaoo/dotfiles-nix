#!/bin/bash
# Use PipeWire (with its PulseAudio server) as the only sound server.
#   Arch: enable the systemd user units (socket activated at login).
#   Void: no systemd, so load wireplumber + pipewire-pulse from pipewire's config and
#         route ALSA through PipeWire; start-dwm starts `pipewire` at login.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib.sh"

# ---------------------------------------------------------------- Arch
setup_arch() {
    local units=(pipewire.socket pipewire-pulse.socket wireplumber.service)
    unit_exists() { systemctl --user list-unit-files "$1" > /dev/null 2>&1; }

    # PulseAudio leftovers (units only exist if the package is still installed).
    for unit in pulseaudio.socket pulseaudio.service; do
        if unit_exists "$unit" && systemctl --user is-enabled "$unit" > /dev/null 2>&1; then
            run systemctl --user disable --now "$unit"
        fi
    done

    if [[ "$DRY_RUN" != "1" ]]; then
        for unit in "${units[@]}"; do
            unit_exists "$unit" || die "$unit not found, is pipewire-pulse installed?"
        done
    fi

    # --now starts them in the current session too (needs a running user manager).
    run systemctl --user enable --now "${units[@]}" || die "Could not enable PipeWire services"
    log_ok "PipeWire enabled: ${units[*]}"
}

# ---------------------------------------------------------------- Void
# Same steps as the Void Handbook (Multimedia > PipeWire).
VOID_LINKS=(
    "/usr/share/examples/wireplumber/10-wireplumber.conf:/etc/pipewire/pipewire.conf.d/10-wireplumber.conf"
    "/usr/share/examples/pipewire/20-pipewire-pulse.conf:/etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf"
    "/usr/share/alsa/alsa.conf.d/50-pipewire.conf:/etc/alsa/conf.d/50-pipewire.conf"
    "/usr/share/alsa/alsa.conf.d/99-pipewire-default.conf:/etc/alsa/conf.d/99-pipewire-default.conf"
)

setup_void() {
    for pair in "${VOID_LINKS[@]}"; do
        local src="${pair%%:*}" dst="${pair#*:}"
        if [[ "$DRY_RUN" != "1" && ! -e "$src" ]]; then
            die "$src not found, are pipewire, wireplumber and alsa-pipewire installed?"
        fi
        if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
            log_ok "$(basename "$dst") already linked"
            continue
        fi
        run sudo mkdir -p "$(dirname "$dst")"
        run sudo ln -sf "$src" "$dst" || die "Could not link $dst"
        log_ok "Linked $dst"
    done
    log_info "PipeWire is started by start-dwm at login (needs the dbus + elogind services)"
}

case "$(detect_distro)" in
    arch) setup_arch ;;
    void) setup_void ;;
    *)    die "Audio setup supports Arch and Void Linux only" ;;
esac
log_info "Apps that were already playing audio (e.g. the browser) need a restart to use PipeWire"
