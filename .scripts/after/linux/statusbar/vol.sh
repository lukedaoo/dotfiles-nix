#!/bin/bash
volume_icon="墳"
volume_value=$(amixer -D pulse sget Master | grep 'Left:' | awk -F'[][]' '{ print $2}')
is_mute=$(pacmd list-sinks | awk '/muted/ { print $2 }')

if [[ $volume_value == "0%" || $is_mute == "yes" ]]
then
    volume_icon="婢"
    volume_value="MUTED"
fi
echo "$volume_value"

