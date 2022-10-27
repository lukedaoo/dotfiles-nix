#!/bin/bash

FILE=.xinitrc

if [ -f $FILE ];
then
    rm -rf $FILE
fi 

comment() {
    echo "#$1" >> $HOME/$FILE
}

_echo() {

    echo "$1" >> $HOME/$FILE
}

comment "!/bin/bash" 
comment "remap capslock to esc"
_echo "setxkbmap -option caps:escape" 

comment "increase repeat key time"
_echo "xset r rate 200 65"

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

comment "enable notification service"
#_echo "/usr/lib/notification-daemon-1.0/notification-daemon &"
_echo "dunst &"

comment "start status bar"
_echo "/usr/local/bin/dwmblocks &"

comment "start dwm"
_echo "/usr/local/bin/dwm"
