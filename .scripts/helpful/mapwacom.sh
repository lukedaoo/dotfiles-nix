#!/bin/bash

DEVICE_ID=$1
SCREEN_NAME=$2
SCREEN_LINE=""

check_tool_exists() {
	command -v $1 >/dev/null 2>&1 || {
		echo "$MAPWACOM requires $1 to run." 1>&2
        exit 1
	}
}

check_tool_exists xrandr
check_tool_exists xsetwacom

if xrandr | grep -q "${SCREEN_NAME} connected"; then
    SCREEN_LINE=$(xrandr | grep "${SCREEN_NAME} connected" | grep -o '[0-9]\+x[0-9]\++[0-9]\++[0-9]\+')
    echo "set out put $DEVICE_ID with $SCREEN_LINE"
    xsetwacom set $DEVICE_ID MapToOutput "$SCREEN_LINE"
    xsetwacom set 19 Area 0 0 32767 18431
else
  echo "Screen ${SCREEN} is not connected."
  exit 1
fi


