#!/bin/bash

FONTS_DIR="$HOME/.fonts"

if [ ! -d $FONTS_DIR ]; then
	mkdir $FONTS_DIR
fi

FONT_DOWNLOAD_URLS=(
	#Comic Nerd fonts
	"https://github.com/xtevenx/ComicMonoNF/raw/master/ComicMonoNF.ttf" 
	"https://github.com/xtevenx/ComicMonoNF/raw/master/ComicMonoNF-Bold.ttf")

if ! command -v curl > /dev/null; then
	echo "Curl is require.. No fonts is installed"
	exit 0
fi

echo "Fonts is installing..."
for url in ${FONT_DOWNLOAD_URLS[@]}; do
	echo $url
	#(cd $FONTS_DIR && curl -O URL)
	curl -L --create-dirs -O --output-dir $FONTS_DIR $url
done

cd $HOME

