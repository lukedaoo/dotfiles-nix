#!/bin/bash
WALLPAPER_DIR="$HOME/.wallpaper";
FEH_FILE="$HOME/.fehbg";

create_wallpaper_randomize() {
    feh --bg-fill --randomize ~/.wallpaper/*
}

start_wallpaper() {
    $FEH_FILE &
}

if ! command -v feh > /dev/null; then

	echo "feh not found"
	return
fi

if [ ! -n "$(ls -A $WALLPAPER_DIR 2>/dev/null)" ]; then
  echo "Wallpaper folder $WALLPAPER_DIR is empty (or does not exist)"
  exit 0
fi

if [ -f $FEH_FILE ];
    then
        start_wallpaper
    else
        create_wallpaper_randomize
fi

if [ -f $FEH_FILE ]; then
	echo "Set wallpaper successfully"
fi

