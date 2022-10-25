#!/bin/bash

if [ -z "$OPT_DIR"]; then 
	OPT_DIR="$HOME/.local/share"
fi
P10K_INSTALL_DIR="$OPT_DIR/p10k"


if [ -d $P10K_INSTALL_DIR ]; then 
	rm -rf $P10K_INSTALL_DIR
else 
	mkdir $P10K_INSTALL_DIR
fi
echo $P10K_INSTALL_DIR
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $P10K_INSTALL_DIR

SOURCE_THEME="$P10K_INSTALL_DIR/powerlevel10k.zsh-theme"

echo "source $SOURCE_THEME" >> ~/.zshrc-deps
echo '[[ ! -f ~/.config/p10k/.p10k.zsh ]] || source ~/.config/p10k/.p10k.zsh' >> ~/.zshrc-deps
