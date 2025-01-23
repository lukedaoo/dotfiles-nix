export ZDOTDIR=$HOME/.config/zsh

export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
export BROWSER="google-chrome-stable"
[ -f "$HOME/.env" ] && source "$HOME/.env"
[ -f "$HOME/.secret" ] && source "$HOME/.secret"
