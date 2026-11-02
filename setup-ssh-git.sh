#!/usr/bin/env bash
# setup-ssh-git.sh — configure SSH authentication for GitHub (idempotent).
#
# Steps:
#   1. set git identity: user.name = ld-<hostname>, user.email = GitHub noreply
#   2. generate an ed25519 key (skipped if it exists)
#   3. trust github.com's host key
#   4. upload the public key to GitHub via gh (skipped if already there)
#   5. make gh and git use SSH instead of HTTPS credentials
#   6. sign commits and tags with the same key (shows "Verified" on GitHub)
#
# Usage: setup-ssh-git.sh [--dry-run] [--validate] [--name NAME] [--email EMAIL]
#                         [--key PATH] [--passphrase] [-h|--help]

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$SCRIPT_DIR/.scripts/lib.sh" ]] \
  || { echo "Cannot find $SCRIPT_DIR/.scripts/lib.sh, run setup-ssh-git.sh from the dotfiles repo" >&2; exit 1; }
source "$SCRIPT_DIR/.scripts/lib.sh"   # log_*, die, run, has_cmd, DRY_RUN

KEY="$HOME/.ssh/id_ed25519"
NAME=""
EMAIL=""
VALIDATE=0
PASSPHRASE=0

usage() {
  cat <<'EOF'
Usage: setup-ssh-git.sh [options]

Sets up SSH auth and SSH commit signing for GitHub.

  --dry-run       Print what would change; modify nothing.
  --validate      Only check the current setup; exit 1 if anything is wrong.
  --name NAME     git user.name (default: ld-<hostname>).
  --email EMAIL   git user.email (default: your GitHub noreply address,
                  <id>+<login>@users.noreply.github.com, looked up via gh).
  --key PATH      Private key path (default: ~/.ssh/id_ed25519).
  --passphrase    Prompt for a key passphrase (default: none, no prompts later).
  -h, --help      Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)    DRY_RUN=1 ;;
    --validate)   VALIDATE=1 ;;
    --passphrase) PASSPHRASE=1 ;;
    --name)       NAME="${2:?--name needs a value}"; shift ;;
    --email)      EMAIL="${2:?--email needs a value}"; shift ;;
    --key)        KEY="${2:?--key needs a value}"; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

PUB="$KEY.pub"
URL_KEY='url.git@github.com:.insteadof'
ALLOWED_SIGNERS="$HOME/.ssh/allowed_signers"

have_gh() { has_cmd gh; }

# True if the local public key is registered on the GitHub account.
key_on_github() {
  have_gh || return 2
  local local_key
  local_key="$(awk '{print $1" "$2}' "$PUB" 2>/dev/null)" || return 2
  [ -n "$local_key" ] || return 2
  gh api user/keys --paginate --jq '.[].key' 2>/dev/null \
    | awk '{print $1" "$2}' | grep -qxF "$local_key"
}

# True if the local public key is registered on GitHub as a *signing* key.
signing_key_on_github() {
  have_gh || return 2
  local local_key
  local_key="$(awk '{print $1" "$2}' "$PUB" 2>/dev/null)" || return 2
  [ -n "$local_key" ] || return 2
  gh api user/ssh_signing_keys --paginate --jq '.[].key' 2>/dev/null \
    | awk '{print $1" "$2}' | grep -qxF "$local_key"
}

gcfg() { git config --global --get "$1" 2>/dev/null; }

set_cfg() { # set_cfg key value — only write when different
  if [ "$(gcfg "$1")" = "$2" ]; then log_info "$1 already $2"
  else run git config --global "$1" "$2"; fi
}

# Work out the identity to configure (flags win over defaults).
resolve_identity() {
  [ -n "$NAME" ] || NAME="ld-$(uname -n)"
  if [ -z "$EMAIL" ] && have_gh; then
    EMAIL="$(gh api user --jq '"\(.id)+\(.login)@users.noreply.github.com"' 2>/dev/null || true)"
  fi
  if [ -z "$EMAIL" ]; then
    EMAIL="$(gcfg user.email || true)"
    [ -z "$EMAIL" ] || log_warn "could not look up noreply email; keeping current: $EMAIL"
  fi
}

gh_protocol() { gh config get git_protocol -h github.com 2>/dev/null; }

has_gh_helper() {
  git config --global --get-regexp '^credential\..*github\.com.*\.helper$' 2>/dev/null \
    | grep -q 'gh auth git-credential'
}

has_rewrite() {
  git config --global --get-all "$URL_KEY" 2>/dev/null | grep -qxF 'https://github.com/'
}

resolve_identity

# ---------------------------------------------------------------- validate
validate() {
  local fail=0
  check() { # check "label" command...
    local label="$1"; shift
    if "$@" >/dev/null 2>&1; then log_ok "$label"
    else log_error "$label"; fail=1; fi
  }
  perms_ok() { [ "$(stat -c %a "$KEY")" = "600" ]; }
  known_host() { ssh-keygen -F github.com >/dev/null 2>&1; }
  ssh_auth() {
    local out
    out="$(ssh -o BatchMode=yes -o ConnectTimeout=10 -T git@github.com 2>&1 || true)"
    printf '%s' "$out" | grep -q 'successfully authenticated'
  }
  proto_ssh() { [ "$(gh_protocol)" = "ssh" ]; }
  no_helper() { ! has_gh_helper; }

  id_name()  { [ "$(gcfg user.name)" = "$NAME" ]; }
  id_email() { [ -n "$EMAIL" ] && [ "$(gcfg user.email)" = "$EMAIL" ]; }
  sign_format() { [ "$(gcfg gpg.format)" = "ssh" ]; }
  sign_key()    { [ "$(gcfg user.signingkey)" = "$PUB" ]; }
  sign_commits(){ [ "$(gcfg commit.gpgsign)" = "true" ]; }
  sign_tags()   { [ "$(gcfg tag.gpgsign)" = "true" ]; }
  signers_ok()  { [ "$(gcfg gpg.ssh.allowedSignersFile)" = "$ALLOWED_SIGNERS" ] \
                    && grep -qF "$(awk '{print $2}' "$PUB")" "$ALLOWED_SIGNERS"; }
  sign_works() { # sign + verify a throwaway message with the real key
    local d; d="$(mktemp -d)" || return 1
    echo test > "$d/m"
    ssh-keygen -Y sign -f "$KEY" -n git "$d/m" >/dev/null 2>&1 \
      && ssh-keygen -Y check-novalidate -n git -f "$PUB" -s "$d/m.sig" < "$d/m" >/dev/null 2>&1
    local rc=$?; rm -rf "$d"; return $rc
  }

  log_step "Validating SSH/git setup"
  check "user.name = $NAME"                  id_name
  check "user.email = ${EMAIL:-<unknown>}"  id_email
  check "private key exists ($KEY)"          test -f "$KEY"
  check "private key permissions are 600"    perms_ok
  check "public key exists ($PUB)"           test -f "$PUB"
  check "github.com in known_hosts"          known_host
  if have_gh; then
    check "key registered on GitHub account" key_on_github
    check "gh git_protocol is ssh"           proto_ssh
    check "key registered as GitHub signing key" signing_key_on_github
  else
    log_error "gh CLI not installed"; fail=1
  fi
  check "no gh HTTPS credential helper"      no_helper
  check "https://github.com/ rewritten to SSH" has_rewrite
  check "ssh -T git@github.com authenticates" ssh_auth
  check "gpg.format = ssh"                   sign_format
  check "user.signingkey = $PUB"             sign_key
  check "commit.gpgsign = true"              sign_commits
  check "tag.gpgsign = true"                 sign_tags
  check "allowed_signers file configured"    signers_ok
  check "test signature creates and verifies" sign_works

  echo
  if [ "$fail" -eq 0 ]; then log_ok "All checks passed."; else log_error "Some checks failed."; fi
  return "$fail"
}

if [ "$VALIDATE" -eq 1 ]; then
  validate
  exit $?
fi

# ------------------------------------------------------------------- setup
command -v ssh-keygen >/dev/null 2>&1 || die "ssh-keygen not found"
command -v git        >/dev/null 2>&1 || die "git not found"
have_gh || die "gh CLI not found (needed to upload the key)"
gh auth status >/dev/null 2>&1 || die "gh not logged in: run 'gh auth login' first"

[ "$DRY_RUN" -eq 1 ] && echo "DRY RUN: no changes will be made."

log_step "1/6 Git identity"
set_cfg user.name "$NAME"
if [ -n "$EMAIL" ]; then set_cfg user.email "$EMAIL"
else log_info "no email known; skipping user.email"; fi

log_step "2/6 SSH key"
if [ -f "$KEY" ]; then
  log_info "exists: $KEY (leaving it alone)"
  if [ ! -f "$PUB" ]; then
    log_info "public key missing; regenerating from private key"
    if [ "$DRY_RUN" -eq 1 ]; then log_info "[dry-run] ssh-keygen -y -f $KEY > $PUB"
    else ssh-keygen -y -f "$KEY" > "$PUB" || die "could not derive public key"; fi
  fi
else
  run mkdir -p "$(dirname "$KEY")"
  run chmod 700 "$(dirname "$KEY")"
  kg=(ssh-keygen -t ed25519 -C "${EMAIL:-$USER@$(uname -n)}" -f "$KEY")
  [ "$PASSPHRASE" -eq 1 ] || kg+=(-N "")
  run "${kg[@]}"
fi
[ "$DRY_RUN" -eq 1 ] || { [ -f "$KEY" ] && chmod 600 "$KEY"; }

log_step "3/6 github.com host key"
if ssh-keygen -F github.com >/dev/null 2>&1; then
  log_info "already in known_hosts"
else
  if [ "$DRY_RUN" -eq 1 ]; then
    log_info "[dry-run] ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts"
  else
    mkdir -p "$HOME/.ssh"
    ssh-keyscan -t ed25519 github.com 2>/dev/null >> "$HOME/.ssh/known_hosts" \
      || die "ssh-keyscan failed"
    log_info "added"
  fi
fi

log_step "4/6 Upload key to GitHub"
# Needs admin:public_key scope; request it if the token lacks it.
if ! gh api user/keys >/dev/null 2>&1; then
  log_info "token lacks the admin:public_key scope"
  run gh auth refresh -h github.com -s admin:public_key
fi
if [ "$DRY_RUN" -eq 1 ] && [ ! -f "$PUB" ]; then
  log_info "[dry-run] would upload the newly generated key"
elif key_on_github; then
  log_info "already registered on your account"
else
  run gh ssh-key add "$PUB" --title "$(uname -n)-$(date +%F)"
fi

log_step "5/6 git / gh configuration"
if [ "$(gh_protocol)" = "ssh" ]; then log_info "gh git_protocol already ssh"
else run gh config set git_protocol ssh -h github.com; fi

if has_gh_helper; then
  for host in github.com gist.github.com; do
    run git config --global --unset-all "credential.https://$host.helper" || true
  done
else
  log_info "no gh HTTPS credential helper present"
fi

if has_rewrite; then log_info "https://github.com/ -> git@github.com: already set"
else run git config --global "$URL_KEY" "https://github.com/"; fi

log_step "6/6 Commit signing"
# Register the same key as a signing key (needs write:ssh_signing_key scope).
if [ "$DRY_RUN" -eq 1 ] && [ ! -f "$PUB" ]; then
  log_info "[dry-run] would register the new key as a signing key"
elif signing_key_on_github; then
  log_info "already registered as a signing key"
else
  if ! gh api user/ssh_signing_keys >/dev/null 2>&1; then
    log_info "token lacks the write:ssh_signing_key scope"
    run gh auth refresh -h github.com -s write:ssh_signing_key
  fi
  run gh ssh-key add "$PUB" --type signing --title "$(uname -n)-signing-$(date +%F)"
fi

# Local verification (git log --show-signature) needs an allowed_signers entry.
if [ -z "$EMAIL" ]; then
  log_info "no email known (git user.email unset, no --email); skipping allowed_signers"
elif [ -f "$PUB" ] && grep -qF "$(awk '{print $2}' "$PUB")" "$ALLOWED_SIGNERS" 2>/dev/null; then
  log_info "allowed_signers already has this key"
elif [ "$DRY_RUN" -eq 1 ]; then
  log_info "[dry-run] append '$EMAIL namespaces=\"git\" <pubkey>' to $ALLOWED_SIGNERS"
else
  printf '%s namespaces="git" %s\n' "$EMAIL" "$(awk '{print $1" "$2}' "$PUB")" >> "$ALLOWED_SIGNERS"
  log_info "added to $ALLOWED_SIGNERS"
fi

set_cfg gpg.format ssh
set_cfg user.signingkey "$PUB"
set_cfg gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS"
set_cfg commit.gpgsign true
set_cfg tag.gpgsign true

if [ "$DRY_RUN" -eq 1 ]; then
  echo; echo "Dry run complete. Re-run without --dry-run to apply."
  exit 0
fi

validate
