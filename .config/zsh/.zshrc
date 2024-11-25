source $ZDOTDIR/zdap
fpath=($ZDOTDIR/plugins/zsh-completions/src $fpath)
autoload -U compinit; compinit

z_source "prompt"
z_source "binding"
z_source "alias"
z_source "function"
z_source "deps"

z_source "custom"

z_plug "zsh-users/zsh-completions"
z_plug "zsh-users/zsh-autosuggestions"

