#!/bin/sh

# defaults
USER=ubuntu
HOST=ubuntu
PASS=$(echo ubuntu | mkpasswd -m sha-512 -s)
SRCID="ubuntu-server-minimal"
LUKSPW="ChangeMe!"
SSHK1="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2yM/uVAf4HQQ4xxs6nMuU3Fjkd9OOSUKOkqPLbuJt5 xps"
SSHK2="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBWL+1W3ds8rtQOXxkhFjvgEzPttRwecbhYruhgtcXJ m2"
PRESET=lvm_luks

gen_lvm_luks() {
  cat <<EOC
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ${HOST}
  source:
    id: ${SRCID}
  user-data:
    users:
      - name: ${USER}
        passwd: "${PASS}"
  ssh:
    install-server: true
    authorized-keys:
      - ${SSHK1}
      - ${SSHK2}
  storage:
    layout:
      name: lvm
      password: "${LUKSPW}"
  packages:
    - clevis-luks
    - vim-tiny
    - iputils-ping
EOC
}

logerr() {
  echo "$@" >&2
}

usage_exit() {
  cat <<EOU
Usage: $SELF [options]

--host <hostname>     set hostname
--user <username>     set username
--password <password> set user password
--source <source-id>  set source id (ubuntu-server etc.)
--luks-pw <disk-encryption-passphrase> set full disk encryption passphrase
--ssh-key1 <ssh-pub-key-1> set a ssh public key for the user
--ssh-key2 <ssh-pub-key-2> set another public key
EOU
  exit
}

while [ $# -gt 0 ]; do
  case $1 in
    --host) HOST=$2; shift;;
    --user) USER=$2; shift;;
    --password) PASS=$(echo "$2" | mkpasswd -m sha-512 -s); shift;;
    --source) SRCID=$2; shift;;
    --luks-pw) LUKSPW=$2; shift;;
    --preset) PRESET=$2; shift;;
    --ssh-key1) SSHK1=$2; shift;;
    --ssh-key2) SSHK2=$2; shift;;
    --help|-h) usage_exit;;
    -*) logerr "Unknown option $1"; usage_exit;;
  esac
  shift
done

gen_"$PRESET"
