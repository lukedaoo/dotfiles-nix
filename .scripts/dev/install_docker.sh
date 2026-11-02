#!/bin/bash
# Docker: installed but NOT started at boot. Start it only when needed:
#   Arch: sudo systemctl start docker      (stop: sudo systemctl stop docker)
#   Void: sudo sv up docker                (stop: sudo sv down docker)
# Also lets the user run docker without sudo.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

has_cmd docker || [[ "$DRY_RUN" == "1" ]] || die "docker not installed"

case "$(detect_distro)" in
    arch)
        # docker.socket would start the daemon on first use, so keep both disabled.
        for unit in docker.service docker.socket; do
            if systemctl is-enabled "$unit" > /dev/null 2>&1; then
                run sudo systemctl disable "$unit" || die "Could not disable $unit"
                log_ok "Disabled $unit at boot"
            fi
        done
        log_ok "docker not started at boot (start: sudo systemctl start docker)"
        ;;
    void)
        # runit starts every linked service unless it has a `down` file.
        # Link it with `down`, so `sv up docker` works but boot does not start it.
        [[ -d /etc/sv/docker || "$DRY_RUN" == "1" ]] || die "/etc/sv/docker not found"
        [[ -f /etc/sv/docker/down ]] || run sudo touch /etc/sv/docker/down || die "Could not create /etc/sv/docker/down"
        [[ -L /var/service/docker ]] || run sudo ln -s /etc/sv/docker /var/service/ || die "Could not link docker service"
        log_ok "docker not started at boot (start: sudo sv up docker)"
        ;;
esac

if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    log_ok "$USER already in docker group"
else
    run sudo usermod -aG docker "$USER" || die "Could not add $USER to docker group"
    log_warn "Added $USER to the docker group: log out and back in before using docker without sudo"
fi
