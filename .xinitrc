#!/bin/bash

session=${1:-dwm}

case $session in 
    dwm     ) exec $HOME/.local/bin/start-dwm;;
    xfce    ) exec startxfce4;;
    *       ) exec $1;;
esac
