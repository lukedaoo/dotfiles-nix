#!/bin/bash
# Bootstrap Claude config: clone repo, install skills, install rtk, validate.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib.sh"

REPO_URL="https://github.com/lukedaoo/.claude"
CLAUDE_INSTALL_URL="https://claude.ai/install.sh"
RTK_INSTALL_URL="https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$HOME/.agents"

FAILURES=0

check_fail() { log_error "$*"; FAILURES=$((FAILURES + 1)); }

ensure_claude_cli() {
    log_step "Check claude CLI"
    if has_cmd claude; then
        log_ok "claude CLI found"
        return
    fi

    log_warn "claude CLI not found"
    [[ -t 0 ]] || die "Install it: curl -fsSL $CLAUDE_INSTALL_URL | bash"

    local answer
    read -r -p "Install claude CLI now? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || die "claude CLI is required"

    if [[ "$DRY_RUN" == "1" ]]; then
        run sh -c "curl -fsSL $CLAUDE_INSTALL_URL | bash"
        return
    fi
    curl -fsSL "$CLAUDE_INSTALL_URL" | bash || die "claude CLI install failed"
    has_cmd claude || die "claude not on PATH (try ~/.local/bin)"
}

clone_repo() {
    log_step "Clone $REPO_URL"
    has_cmd git || die "git is not installed"

    if [[ -d "$CLAUDE_DIR/.git" ]]; then
        run git -C "$CLAUDE_DIR" pull --ff-only || die "git pull failed"
        return
    fi

    if [[ ! -e "$CLAUDE_DIR" ]]; then
        run git clone "$REPO_URL" "$CLAUDE_DIR" || die "git clone failed"
        return
    fi

    log_info "$CLAUDE_DIR exists without git; merging without overwriting"
    local tmp
    tmp="$(mktemp -d)"
    run git clone "$REPO_URL" "$tmp/repo" || die "git clone failed"
    run cp -rn "$tmp/repo/." "$CLAUDE_DIR/"
    rm -rf "$tmp"
}

install_skills() {
    log_step "Install skills"
    [[ "$DRY_RUN" == "1" ]] && { run "$CLAUDE_DIR/install-skills.sh"; return; }
    (cd "$CLAUDE_DIR" && ./install-skills.sh) || die "install-skills.sh failed"
}

link_global_skills() {
    log_step "Link global skills into $CLAUDE_DIR/skills"
    [[ -d "$AGENTS_DIR/skills" ]] || { log_warn "no $AGENTS_DIR/skills"; return; }

    run mkdir -p "$CLAUDE_DIR/skills"

    local src name dest
    for src in "$AGENTS_DIR"/skills/*/; do
        name="$(basename "$src")"
        dest="$CLAUDE_DIR/skills/$name"
        if [[ -e "$dest" || -L "$dest" ]]; then
            log_info "skip $name (exists)"
            continue
        fi
        run ln -s "${src%/}" "$dest"
    done
}

install_rtk() {
    log_step "Install rtk"
    if has_cmd rtk; then
        log_ok "rtk already installed"
        return
    fi

    has_cmd curl || die "curl is not installed"
    if [[ "$DRY_RUN" == "1" ]]; then
        run sh -c "curl -fsSL $RTK_INSTALL_URL | sh"
        return
    fi
    curl -fsSL "$RTK_INSTALL_URL" | sh || die "rtk install failed"
}

# Skill names from skills.conf: skip comments, sections, blanks, KEY=VALUE.
conf_skills() {
    grep -vE '^\s*(#|\[|$)|=' "$CLAUDE_DIR/skills.conf" | tr -d ' \t'
}

validate_claude_skills() {
    local skill
    while read -r skill; do
        if [[ -d "$CLAUDE_DIR/skills/$skill" ]]; then
            log_ok "claude skill: $skill"
        else
            check_fail "missing $CLAUDE_DIR/skills/$skill"
        fi
    done < <(conf_skills)
}

# Global skills are the ones recorded in ~/.agents/.skill-lock.json.
lock_skills() {
    python3 -c 'import json,sys; print("\n".join(json.load(open(sys.argv[1]))["skills"]))' "$AGENTS_DIR/.skill-lock.json"
}

validate_global_skills() {
    if [[ ! -f "$AGENTS_DIR/.skill-lock.json" ]]; then
        check_fail "missing $AGENTS_DIR/.skill-lock.json"
        return
    fi

    local skill
    while read -r skill; do
        if [[ -d "$AGENTS_DIR/skills/$skill" ]]; then
            log_ok "global skill: $skill"
        else
            check_fail "missing $AGENTS_DIR/skills/$skill"
        fi
    done < <(lock_skills)
}

validate_agent_md() {
    if [[ -f "$AGENTS_DIR/agent.md" ]]; then
        log_ok "$AGENTS_DIR/agent.md"
    else
        check_fail "missing $AGENTS_DIR/agent.md"
    fi
}

validate_rtk() {
    if has_cmd rtk && rtk gain > /dev/null 2>&1; then
        log_ok "rtk"
    else
        check_fail "rtk missing or wrong binary (check PATH)"
    fi
}

validate() {
    log_step "Validate"
    validate_claude_skills
    validate_global_skills
    validate_agent_md
    validate_rtk

    (( FAILURES == 0 )) || die "$FAILURES check(s) failed"
    log_ok "All checks passed"
}

if [[ "${1:-}" == "--link-global-skills" ]]; then
    link_global_skills
    exit 0
fi

ensure_claude_cli
clone_repo
install_skills
link_global_skills
install_rtk
validate
