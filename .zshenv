export ZDOTDIR=$HOME/.config/zsh

export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
# google-chrome on Arch (AUR); Void has no google-chrome package, use chromium there
if command -v google-chrome-stable > /dev/null; then export BROWSER="google-chrome-stable"; else export BROWSER="chromium"; fi

[ -f "$HOME/.env" ] && source "$HOME/.env"
[ -f "$HOME/.secret" ] && source "$HOME/.secret"
export TERM="xterm-256color"
