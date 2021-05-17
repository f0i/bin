#!/usr/bin/env bash

wm=$(loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}')

if [ "$wm" = "wayland" ]
then
  #echo "on wayland"
  grim -g "$(slurp)"
else
  #echo "on X11"
  scrot -s --exec 'emv $f'
fi

