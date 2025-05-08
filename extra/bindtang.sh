#!/bin/sh

TANGURL=$1
LUKSPW=$2

sudo lsblk -lo NAME,FSTYPE | grep LUKS | cut -f1 -d' ' | \
  sed 's/\(.*\)/\/dev\/\1/' | \
  while read -r disk; do
    echo "$LUKSPW" | sudo clevis luks bind -y -k - -d "$disk" tang '{"url":"'"$TANGURL"'"}'
  done
