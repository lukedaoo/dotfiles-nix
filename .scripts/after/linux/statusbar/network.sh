#!/bin/bash
tool_path="/usr/sbin/iwgetid"
ssid=$($tool_path -r)

char="直  睊"

if [[ $ssid != "" ]]
then
    echo $ssid
else
    echo "Not Connected"
fi

