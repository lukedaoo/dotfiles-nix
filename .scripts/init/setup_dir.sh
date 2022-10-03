#!/bin/bash

DEFAULT_OPT_DIR="$HOME/.local/share"
DEFAULT_RUNTIME_LIB_DIR="$HOME/.runtime-lib"
DEFAULT_WORKSPACE_DIR="$HOME/Work"
DEFAULT_WALLPAPER_DIR="$HOME/.wallpaper"
DEFAULT_TRASH_DIR=$HOME/.trash

createIfNotExist() {

	dir=$1
	if [ ! -d $dir ]; then
		echo "Create $dir folder"
		mkdir $dir
	fi
}

createOptDir() {
	createIfNotExist $DEFAULT_OPT_DIR
}

createRuntimeLibDir() {
	createIfNotExist $DEFAULT_RUNTIME_LIB_DIR
}

createWorkspaceDir() {
	createIfNotExist $DEFAULT_WORKSPACE_DIR
}

createWallpaperDir() {
	createIfNotExist $DEFAULT_WALLPAPER_DIR
}

createTrashDir() {
    createIfNotExist $DEFAULT_TRASH_DIR
}

run() {
	createOptDir
	createRuntimeLibDir
	createWorkspaceDir
	createWallpaperDir
    createTrashDir
}

run
