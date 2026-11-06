#!/bin/bash
# Check every dev tool setup-dev.sh installs. Exits non-zero if any check fails.
# Tools that live in your shell config (sdkman, nvm, conda) are checked by their files,
# because this script does not run inside your zsh session.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

pass=0; fail=0
check() {
    local desc="$1"; shift
    if "$@" > /dev/null 2>&1; then
        log_ok "$desc"; pass=$((pass + 1))
    else
        log_error "$desc"; fail=$((fail + 1))
    fi
}

# Run a command and also show its version line.
check_version() {
    local desc="$1"; shift
    local out
    if out="$("$@" 2>&1 | head -1)" && [[ -n "$out" ]]; then
        log_ok "$desc: $out"; pass=$((pass + 1))
    else
        log_error "$desc"; fail=$((fail + 1))
    fi
}

in_docker_group() { id -nG "$USER" | tr ' ' '\n' | grep -qx docker; }
nvm_node() { bash -c 'source "$HOME/.nvm/nvm.sh" && nvm exec default node --version' 2>/dev/null | tail -1; }

log_step "Validating dev tools ($(detect_distro))"

SDK="$HOME/.sdkman/candidates"
check_version "java (sdkman)"   "$SDK/java/current/bin/java" -version
# mvn refuses to run without JAVA_HOME; zsh gets it from sdkman-init, this script does not.
check_version "maven (sdkman)"  env JAVA_HOME="$SDK/java/current" "$SDK/maven/current/bin/mvn" --version

check         "nvm (~/.nvm)"    test -s "$HOME/.nvm/nvm.sh"
check_version "node (nvm default)" nvm_node
# default must point at the LTS alias and resolve to an installed LTS version
nvm_default_is_lts() {
    bash -c 'source "$HOME/.nvm/nvm.sh" > /dev/null 2>&1
             [[ "$(cat "$NVM_DIR/alias/default" 2>/dev/null)" == "lts/*" ]] &&
             v="$(nvm version "lts/*")" && [[ "$v" == v* && "$(nvm version default)" == "$v" ]]'
}
check "node default is LTS (nvm alias default lts/*)" nvm_default_is_lts

check_version "conda (/opt/miniconda3)" /opt/miniconda3/bin/conda --version

check_version "docker"          docker --version
docker_not_at_boot() {
    case "$(detect_distro)" in
        arch) ! service_enabled docker.service && ! service_enabled docker.socket ;;
        void) [[ -f /etc/sv/docker/down ]] || [[ ! -L /var/service/docker ]] ;;
    esac
}
check "docker not started at boot" docker_not_at_boot
check "user in docker group (re-login after first install)" in_docker_group

check_version "postgresql"      postgres --version
postgres_not_at_boot() {
    case "$(detect_distro)" in
        arch) ! service_enabled postgresql.service ;;
        void) [[ -f /etc/sv/postgresql/down ]] || [[ ! -L /var/service/postgresql ]] ;;
    esac
}
check "postgresql not started at boot" postgres_not_at_boot

check_version "gdb"             gdb --version
check         "gf2 (~/.local/bin/gf2)" test -x "$HOME/.local/bin/gf2"
case "$(detect_distro)" in
    arch) check "clion (AUR)" has_cmd clion ;;
    void) log_info "clion: not available on Void, skipped" ;;
esac

check_version "vscode (code)"   code --version
check_version "rustc"           rustc --version
check_version "cargo"           cargo --version
check_version "go"              go version
check_version "tree-sitter cli" tree-sitter --version

echo
if (( fail )); then
    log_error "$fail check(s) failed, $pass passed"
    exit 1
fi
log_ok "All $pass dev checks passed"
