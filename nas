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
  "wm" | \
  "wake-mount")
    ~/bin/qnap/wake \
      && ~/bin/qnap/mount
    ;;
  "wake")
    ~/bin/qnap/wake
    ;;
  "sleep")
    ~/bin/qnap/sleep
    ;;
  "wq" | \
  "us" | \
  "unmount-sleep")
    fusermount -u "$NAS_MOUNT" \
    && ~/bin/qnap/sleep
    ;;
  "unlock")
    scp $NAS_KEY $NAS_USER@$NAS_IP:/tmp/qnap.key \
      && ssh $NAS_USER@$NAS_IP "cryptsetup -v luksOpen /dev/vg1/lv1 decrypt --key-file=/tmp/qnap.key ; rm /tmp/qnap.key ; mount /dev/mapper/decrypt /mnt/qnap"
    ;;
  "lock")
    ssh  $NAS_USER@$NAS_IP "sync && umount /mnt/qnap"
    ssh  $NAS_USER@$NAS_IP "cryptsetup -v luksClose decrypt"
    exit 1
    ;;
  *)
    echo "usage:"
    echo " $0 mount"
    echo " $0 unmount"
    echo " $0 ssh [<user>]"
    echo " $0 wake"
    echo " $0 wake-mount"
    echo " $0 sleep"
    echo " $0 unmount-sleep"
    echo " $0 unlock"
    echo " $0 lock"
    exit 1
    ;;
esac

exit $?
