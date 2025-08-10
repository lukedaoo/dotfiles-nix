#!/bin/bash

session=${1:-i3}

xrdb ~/.Xresources
case $session in 
    dwm     ) exec $HOME/.local/bin/start-dwm ;;
    i3      ) exec i3 ;;
    xfce    ) exec startxfce4 ;;
    *       ) exec $1 ;;
esac
