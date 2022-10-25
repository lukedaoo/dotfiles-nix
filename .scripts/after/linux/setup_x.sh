#!/bin/bash

FILE=.xinitrc
comment() {
    echo "#$1" >> $HOME/$FILE
}

_echo() {

    echo "$1" >> $HOME/$FILE
}

comment "!/bin/bash" 
comment "remap capslock to esc"
_echo "setxkbmap -option caps:escape" 

comment "start layout"
_echo "if [ -f ~/.screenlayout/default.sh ] ; then"
_echo "  ~/.screenlayout/default.sh"
_echo "fi"

comment "start wallpaper"
_echo "if [ -f ~/.fehbg ] ; then"
_echo "  ~/.fehbg &"
_echo "fi"

comment "enable alpha feautre"
_echo "xcompmgr &"

comment "start status bar"
_echo "/usr/local/bin/slstatus &"

comment "start dwm"
_echo "/usr/local/bin/dwm"
