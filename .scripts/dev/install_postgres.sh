#!/bin/bash
# PostgreSQL: installed and initialised but NOT started at boot. Start it only when needed:
#   Arch: sudo systemctl start postgresql  (stop: sudo systemctl stop postgresql)
#   Void: sudo sv up postgresql            (stop: sudo sv down postgresql)
# First start: create a superuser role for yourself:
#   sudo -u postgres createuser --superuser $USER && createdb $USER
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

has_cmd initdb || [[ "$DRY_RUN" == "1" ]] || die "postgresql not installed"

case "$(detect_distro)" in
    arch) PG_DATA=/var/lib/postgres/data ;;
    void) PG_DATA=/var/lib/postgresql/data ;;
esac

if sudo test -f "$PG_DATA/PG_VERSION"; then
    log_ok "Cluster already initialised ($PG_DATA)"
else
    run sudo -u postgres initdb -D "$PG_DATA" --locale=C.UTF-8 --encoding=UTF8 --auth-local=peer --auth-host=scram-sha-256 \
        || die "initdb failed"
    log_ok "Initialised cluster ($PG_DATA)"
fi

case "$(detect_distro)" in
    arch)
        if systemctl is-enabled postgresql.service > /dev/null 2>&1; then
            run sudo systemctl disable postgresql.service || die "Could not disable postgresql.service"
        fi
        log_ok "postgresql not started at boot (start: sudo systemctl start postgresql)"
        ;;
    void)
        # runit starts every linked service unless it has a `down` file.
        [[ -d /etc/sv/postgresql || "$DRY_RUN" == "1" ]] || die "/etc/sv/postgresql not found"
        [[ -f /etc/sv/postgresql/down ]] || run sudo touch /etc/sv/postgresql/down || die "Could not create /etc/sv/postgresql/down"
        [[ -L /var/service/postgresql ]] || run sudo ln -s /etc/sv/postgresql /var/service/ || die "Could not link postgresql service"
        log_ok "postgresql not started at boot (start: sudo sv up postgresql)"
        ;;
esac
