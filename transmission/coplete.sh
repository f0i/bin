#!/bin/bash

TR_DOWNLOADS="$TR_TORRENT_DIR/$TR_TORRENT_NAME"

if [ "$TR_DOWNLOADS" = "/" ]
then
  notify-send -u critical "Invalid env" "$0 $*"
  exit 1;
fi

du=`du -hs "$TR_DOWNLOADS" | sed 's/[^0-9.mkg].*//i' 2>/dev/null`

notify-send -u critical "Done" $du
