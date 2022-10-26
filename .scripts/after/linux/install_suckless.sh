#!/bin/bash
clone() {
    git clone $1
}

SUCKLESS_CONFIG_DIR="$HOME/.config/"
SUCKLESS_GIT_REPO="https://git.suckless.org/"
SUCKLESS_SOFTWARE=("dwm" "st" "slstatus" "dwmblocks-async")

MY_SUCKLESS="https://github.com/lukedaoo/suckless"


INSTALLED_SUCKLESS_DIR="unknown"

clone_original_suckless() {
	SUCKLESS_DIR="$SUCKLESS_CONFIG_DIR/suckless"

	if [ ! -d $SUCKLESS_DIR ]; then
		mkdir $SUCKLESS_DIR
	else 
		rm -rf $SUCKLESS_DIR
		mkdir $SUCKLESS_DIR
	fi
    	cd $SUCKLESS_DIR 
    	for repo in ${SUCKLESS_SOFTWARE[@]}; do
		if [ ! -d "$SUCKLESS_DIR/$repo" ]; then
			clone "$SUCKLESS_GIT_REPO/$repo"
		fi
    	done

	INSTALLED_SUCKLESS_DIR=$SUCKLESS_DIR
}

clone_my_suckless() {
	SUCKLESS_DIR=$SUCKLESS_CONFIG_DIR
	SUCKLESS_FULL_DIR="$SUCKLESS_CONFIG_DIR/suckless"
	if [ ! -d $SUCKLESS_FULL_DIR ]; then
		mkdir $SUCKLESS_FULL_DIR
	else 
		rm -rf $SUCKLESS_FULL_DIR
	fi
    	cd $SUCKLESS_DIR 
	clone $MY_SUCKLESS

	INSTALLED_SUCKLESS_DIR=$SUCKLESS_FULL_DIR
}


#clone_original_suckless $@
clone_my_suckless $@

install() {

	if [[ $INSTALLED_SUCKLESS_DIR == "unknown" ]]; then
		INSTALLED_SUCKLESS_DIR="$SUCKLESS_CONFIG_DIR/suckless"
	fi
	for item in ${SUCKLESS_SOFTWARE[@]}; do 
		cd "$INSTALLED_SUCKLESS_DIR/$item"
		sudo make uninstall
		sudo make install
	done
}


install 









