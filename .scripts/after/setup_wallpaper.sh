#!/bin/bash

WALLPAPER_DIR="$HOME/.wallpaper";

if ! command -v feh > /dev/null; then

	echo "feh not found"
	return
fi

FEH_FILE="$HOME/.fehbg";


# random wallpaper
if [ ! -n "$(ls -A $WALLPAPER_DIR 2>/dev/null)" ]; then
  echo "Wallpaper folder $WALLPAPER_DIR is empty (or does not exist)"
  exit 0
fi

if [ -f $FEH_FILE ]; then
	rm -f $FEH_FILE
fi

feh --bg-fill --randomize ~/.wallpaper/*

if [ -f $FEH_FILE ]; then
	echo "Set wallpaper successfully"
fi

