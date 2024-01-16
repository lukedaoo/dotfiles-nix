export ZDOTDIR=$HOME/.config/zsh

export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

[ -f "$HOME/.env" ] && source "$HOME/.env"
[ -f "$HOME/.env" ] && source "$HOME/.secret"
