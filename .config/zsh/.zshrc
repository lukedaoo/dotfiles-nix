source $ZDOTDIR/zdap
fpath=($ZDOTDIR/plugins/zsh-completions/src $fpath)
autoload -U compinit; compinit

__git_files () { 
    _wanted files expl 'local files' _files     
}

z_source "prompt"
z_source "binding"
z_source "alias"
z_source "function"
z_source "deps-conda"

z_source "custom"

z_plug "zsh-users/zsh-completions"
z_plug "zsh-users/zsh-autosuggestions"

