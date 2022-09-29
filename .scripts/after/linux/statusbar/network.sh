#!/bin/bash
tool_path="/usr/sbin/iwgetid"
ssid=$($tool_path -r)


if [[ $ssid != "" ]]
then
    echo 直 $ssid
else
    echo "睊 Not Connected"
fi

