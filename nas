#!/usr/bin/env bash
#
# NAS tools

. ~/.nas || exit 1


case "$1" in
  "mount")
    ~/bin/qnap/mount
    ;;
  "unmount")
    fusermount -u "$NAS_MOUNT"
    ;;
  "ssh")
    user=${2:-$NAS_USER} 
    echo "Login to $NAS_IP as $user"
    ssh $user@$NAS_IP
    ;;
  "wake")
    ~/bin/qnap/wake
    ;;
  "sleep")
    ~/bin/qnap/sleep
    ;;
  "unlock")
    echo TODO
    exit 1
    ;;
  "lock")
    echo TODO
    exit 1
    ;;
  *)
    echo "usage:"
    echo " $0 mount"
    echo " $0 ssh [<user>]"
    echo " $0 wake"
    echo " $0 sleep"
    echo " $0 unlock"
    echo " $0 lock"
    ;;
esac
