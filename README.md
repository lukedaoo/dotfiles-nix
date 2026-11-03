# dotfiles

Arch Linux + dwm setup.

## New PC

The dotfiles live in a bare git repo (`~/.dotfiles`) whose work tree is `~`.
Files are checked out in place, so `~/setup.sh` is the script and `config commit` / `config push` work from day one.

1. Install Arch, create your user (with sudo), connect to the internet.
2. Install git and check out the dotfiles:

   ```sh
   sudo pacman -S --needed git
   git clone --bare https://github.com/lukedaoo/dotfiles-nix ~/.dotfiles
   alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   config config --local status.showUntrackedFiles no
   if ! config checkout 2>/dev/null; then
     # move conflicting files (e.g. .bashrc) aside instead of overwriting them
     mkdir -p ~/.dotfiles-backup/pre-checkout
     config checkout 2>&1 | awk '/^\s+/ {print $1}' | while read -r f; do
       mkdir -p ~/.dotfiles-backup/pre-checkout/"$(dirname "$f")"
       mv ~/"$f" ~/.dotfiles-backup/pre-checkout/"$f"
     done
     config checkout
   fi
   grep -q "alias config=" ~/.bashrc \
     || echo "alias config='git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'" >> ~/.bashrc
   ```

   Moved files are kept in `~/.dotfiles-backup/pre-checkout/`.
3. Run setup from your home directory. Either everything at once:

   ```sh
   cd ~
   ./all.sh --dry-run   # preview, changes nothing
   ./all.sh
   ```

   or just the base system, adding the optional parts yourself later:

   ```sh
   ./setup.sh --dry-run
   ./setup.sh
   ```

   Run as your user, not root. It asks for the sudo password. `all.sh` also pauses twice for you:
   1. `gh auth login` (browser or device code), unless `gh` is already logged in.
   2. Choosing a passphrase for the new SSH key (type it twice). Remember it: it cannot be recovered. Use
      `./all.sh --no-passphrase` to skip this.

   See [all.sh](#allsh-everything-at-once).
4. Log out and back in to start dwm.
5. If you used `setup.sh` only, the optional parts (opt-in; `setup.sh` never runs them):
   - [GitHub SSH + commit signing](#optional-github-ssh--commit-signing): `./setup-ssh-git.sh`
   - [Dev tools](#optional-dev-tools): `./setup-dev.sh`

### Alternative: clone and copy

Use this if you do not want git state in `~`. Files are copied into `~`, and changed ones are backed up first.

```sh
sudo pacman -S --needed git
git clone https://github.com/lukedaoo/dotfiles-nix ~/dotfiles-nix
cd ~/dotfiles-nix
./setup.sh --dry-run
./setup.sh
```

Run the optional scripts from `~/dotfiles-nix` in this case.

## What setup.sh does

1. Checks: Arch, not root, git, internet.
2. Copies tracked dotfiles into `~`. Changed files are backed up to `~/.dotfiles-backup/<time>/`.
   Skipped when the repo is `~` itself (the bare-repo steps above), since the files are already in place.
3. Installs packages (`pacman -Syu`), yay, and AUR packages (google-chrome, physlock).
4. Installs ComicMono Nerd Font, Arc GTK theme, nvim config (ztnvim), suckless (dwm, st, slstatus, dwmblocks), wallpaper.
5. Validates everything and exits with an error if something is missing.

It is safe to run again: installed things are skipped.

## Options

```sh
./setup.sh --dry-run         # show what would happen
./setup.sh --skip-packages   # skip pacman/yay
./setup.sh --validate-only   # only run the checks
```

## all.sh: everything at once

Runs `setup.sh`, then `setup-ssh-git.sh`, then `setup-dev.sh`. Each script still works on its own.

```sh
./all.sh --dry-run         # preview, changes nothing
./all.sh
./all.sh --validate-only   # run every validation, change nothing
```

Options: `--skip-packages` (passed to `setup.sh`), `--skip-ssh`, `--skip-dev`, `--no-passphrase`.

- If `setup.sh` fails it stops, because the other steps need its packages. A failure in the SSH or dev step does
  not stop the rest; the failures are listed at the end and the exit code is 1.
- If `gh` is not logged in it runs `gh auth login` for you, which is the only interactive step besides sudo.
  With no terminal it skips the SSH step and reports the error.

## Optional: GitHub SSH + commit signing

Not run by `setup.sh`. Run it after `setup.sh`, which installs `git`, `openssh` and `gh` (`github-cli`).
If you used `--skip-packages`, install those three first.

```sh
gh auth login                 # interactive: browser or device code
./setup-ssh-git.sh --dry-run  # preview, changes nothing
./setup-ssh-git.sh
./setup-ssh-git.sh --validate # check only, exits 1 if something is wrong
```

It does the following. It is safe to run again:

1. Sets `user.name` to `ld-<hostname>` and `user.email` to your GitHub noreply address
   (`<id>+<login>@users.noreply.github.com`, looked up through `gh`).
2. Generates `~/.ssh/id_ed25519` if missing. Run on its own, the script makes a key with no passphrase unless you
   pass `--passphrase` (`all.sh` passes it for you). See [Passphrase](#passphrase). An existing key is never touched.
3. Trusts the github.com host key.
4. Uploads the key to your GitHub account twice: once to log in, once to sign commits.
   If your `gh` token lacks the scopes, it runs `gh auth refresh` first.
5. Makes `gh` and git use SSH: removes the `gh` HTTPS credential helper and rewrites
   `https://github.com/` to `git@github.com:`.
6. Turns on SSH signing for commits and tags, and adds your key to `~/.ssh/allowed_signers`
   so `git log --show-signature` works.

Options: `--name NAME`, `--email EMAIL`, `--key PATH`, `--passphrase` (ask for a key passphrase when generating).

### Passphrase

With a passphrase, git asks for it each time it signs a commit and each time it connects to GitHub, so a
commit plus a push means two prompts. Nothing is cached unless you add the key to `ssh-agent`.
Without a passphrase nothing prompts, but anyone who copies `~/.ssh/id_ed25519` can push and sign as you.

- New machine: `./setup-ssh-git.sh --passphrase` (needs a terminal).
- Existing key: `ssh-keygen -p -f ~/.ssh/id_ed25519`. The passphrase cannot be recovered; if you forget it,
  delete the key and run the script again.
- Cache it for a session instead of typing it every time: `ssh-add ~/.ssh/id_ed25519`.
- Prompts appear in the terminal running git. Git run from a GUI or editor without a terminal cannot ask,
  and fails unless an `ssh-askpass` program is installed.
- `--validate` skips its `ssh -T` and test-signature checks when the key has a passphrase and is not in
  `ssh-agent`, because they would prompt. Test by hand: `ssh -T git@github.com` and
  `git commit --allow-empty -m test`.
- `all.sh` passes `--passphrase` for you, so it asks for the passphrase when it generates a new key (an existing
  key is left alone). Use `./all.sh --no-passphrase` to skip that.

### By hand

The same thing without the script. Every command can be pasted as is: `$EMAIL` is looked up from your
GitHub account (the noreply address, also shown at <https://github.com/settings/emails>).

```sh
# 0. Log in to GitHub and look up your noreply email.
gh auth login
EMAIL=$(gh api user --jq '"\(.id)+\(.login)@users.noreply.github.com"')
echo "$EMAIL"   # e.g. 45717015+lukedaoo@users.noreply.github.com

# 1. Key. ssh-keygen asks for a passphrase; press Enter twice for none.
ssh-keygen -t ed25519 -C "$EMAIL"
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts

# 2. Upload it to GitHub, once for login and once for signing.
gh auth refresh -h github.com -s admin:public_key,write:ssh_signing_key
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(uname -n)"
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing --title "$(uname -n)-signing"

# 3. Identity, SSH instead of HTTPS, and signing.
git config --global user.name "ld-$(uname -n)"
git config --global user.email "$EMAIL"
git config --global url."git@github.com:".insteadOf "https://github.com/"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# 4. Let git verify your own signatures locally.
echo "$EMAIL namespaces=\"git\" $(cut -d' ' -f1,2 ~/.ssh/id_ed25519.pub)" \
  >> ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

Then check with `ssh -T git@github.com` and `./setup-ssh-git.sh --validate`.

Also turn on "Keep my email addresses private" and "Block command line pushes that expose my email"
at <https://github.com/settings/emails>. The script cannot change those.

Check it with `git commit --allow-empty -m test && git log --show-signature -1`.

## Optional: dev tools

Not run by `setup.sh`. Run it after `setup.sh`. It installs Java and Maven (sdkman), Node (nvm),
Miniconda, Docker, gf2, CLion (Arch), VS Code, Rust, Go and the tree-sitter CLI.

```sh
./setup-dev.sh --dry-run        # preview
./setup-dev.sh
./setup-dev.sh --validate-only  # only run the checks
```

## Change things

- Packages: `.scripts/packages-arch.sh` (Void: `.scripts/packages-void.sh`)
- Checks: `.scripts/after/validate.sh`

## After setup

- Chrome fonts: `chrome://settings/fonts` → Comic Code.
- Optional extras: `.scripts/after/install_{nvm,rust,sdkman,java_dap}.sh`.
