#!/bin/bash

SELF=${0##*/}

# defaults
NAME=ubuntu
RAMMB=1623
VCPUS=2
DISKGB=12.3
ISO=/var/lib/iso/ubuntu-25.04-live-server-amd64.iso
AIURL=https://skyc2.github.io/autoinstall/deploy/ubuntu


usage_exit() {
  cat <<EOU
Usage: $SELF [options]

--name <vm-name>    set instance name
--ram <ram-size-mb> set memory size in MB for the instance
--cpus <num-vcpus>  set number of vcpus for the instance
--disk-size <disk-size> set install disk size in GB
--iso <iso-path-or-url> set installer iso location
--autoinstall-url <autoinstall-url> set autoinstall url
--add-disk <libvirt-disk-spec> add additional storage
--boot <libvirt-boot-spec> set boot options (uefi etc.)
--launchSecurity <libvirt-launch-security-spec> set launch security options
--help              show this help 
--verbose           turn on verbose output
EOU
  exit
}

logerr() {
  echo "$(date -Iseconds): ERROR: $*" >&2
}

ainstall() {
  time virt-install --connect qemu:///system \
  --name "$NAME" --ram "$RAMMB" --vcpus "$VCPUS" \
  --disk size=$DISKGB \
  --graphics none \
  --console pty,target_type=serial --noautoconsole \
  --location "$ISO",kernel=casper/vmlinuz,initrd=casper/initrd \
  --install kernel_args="console=ttyS0,115200n8 serial autoinstall ds=nocloud-net;s=$AIURL" \
  --wait -1  "${XIARGS[@]}" &

  sleep 10
  virsh console "$NAME"
}

while [ $# -gt 0 ]; do
  case $1 in
    --name|-n) NAME=$2; shift;;
    --ram|--memory|-m) RAMMB=$2; shift;;
    --cpus|-c) VCPUS=$2; shift;;
    --disk-size|-d) DISKGB=$2; shift;;
    --iso) ISO=$2; shift;;
    --autoinstall-url) AIURL=$2; shift;;
    --boot|--launchSecurity) XIARGS+=("$1" "$2"); shift;;
    --add-disk) XIARGS+=("--disk" "$2"); shift;;
    --help|-h) usage_exit;;
    --verbose|-v) DEBUG=1;;
    -*) logerr "Unknown option $1"; usage_exit;;
  esac
  shift
done

[ "$DEBUG" ] && set -x

ainstall
