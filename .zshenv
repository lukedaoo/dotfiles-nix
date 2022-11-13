export ZDOTDIR=$HOME/.config/zsh

export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"

#  ff
export WALLPAPER_DIR="$HOME/.wallpaper"
export RUNTIME_LIB_DIR="$HOME/.runtime-lib"
export DATA_DIR="$HOME/.local/share"
export WORKSPACE_DIR="$HOME/Work"
export SOFTWARE_DIR="$HOME/Software"

export SCRIPT_DIR="$HOME/.scripts"

export PATH=$PATH:$HOME/.local/bin/statusbar
export PATH=$PATH:$HOME/Software/idea-IC/bin
export PATH=$PATH:$HOME/.runtime-lib/flutter/bin

# typing 
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

export FLUTTER_HOME="$HOME/.runtime-lib/flutter"
export ANDROID_SDK_ROOT='/opt/android-sdk'
# android tools
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
