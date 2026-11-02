# dotfiles

Arch Linux + dwm setup.

## New PC

1. Install Arch, create your user (with sudo), connect to the internet.
2. Clone and run:

   ```sh
   sudo pacman -S --needed git
   git clone https://github.com/lukedaoo/dotfiles-nix ~/dotfiles-nix
   cd ~/dotfiles-nix
   ./setup.sh --dry-run   # preview, changes nothing
   ./setup.sh
   ```

   Run as your user, not root. It asks for the sudo password once.
3. Log out and back in to start dwm.

## What setup.sh does

1. Checks: Arch, not root, git, internet.
2. Copies tracked dotfiles into `~`. Changed files are backed up to `~/.dotfiles-backup/<time>/`.
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

## Change things

- Packages: `.scripts/packages.sh`
- Checks: `.scripts/after/validate.sh`

## Track dotfiles with git (optional)

```sh
git clone --bare https://github.com/lukedaoo/dotfiles-nix ~/.dotfiles
alias config='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
config config status.showUntrackedFiles no
config reset          # load index, does not touch files
config status
```

## After setup

- Chrome fonts: `chrome://settings/fonts` → Comic Code.
- Optional extras: `.scripts/after/install_{nvm,rust,sdkman,java_dap}.sh`, `setup_git.sh <name> <email>`.
