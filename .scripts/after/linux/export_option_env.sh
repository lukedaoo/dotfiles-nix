#!/bin/bash

ZSH_FILE=".zshrc-env"

echo "export PATH=\$PATH:\$HOME/.local/bin/statusbar" >> $HOME/$ZSH_FILE

# typing method
echo "export GTK_IM_MODULE=fcitx" >> $HOME/$ZSH_FILE
echo "export QT_IM_MODULE=fcitx" >> $HOME/$ZSH_FILE
echo "export XMODIFIERS=@im=fcitx" >> $HOME/$ZSH_FILE
