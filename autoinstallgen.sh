#!/bin/sh

# defaults
USER=ubuntu
HOST=ubuntu
PASS=$(echo ubuntu | mkpasswd -m sha-512 -s)
SRCID="ubuntu-server-minimal"
LUKSPW="ChangeMeAFTERInstallation!"
SSHK1="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2yM/uVAf4HQQ4xxs6nMuU3Fjkd9OOSUKOkqPLbuJt5 xps"
SSHK2="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBWL+1W3ds8rtQOXxkhFjvgEzPttRwecbhYruhgtcXJ m2"
PRESET=lvm_luks

gen_lvm_luks() {
  cat <<EOC > "$OUTFILE"
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ${HOST}
    username: ${USER}
    password: "${PASS}"
  source:
    id: ${SRCID}
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
    - clevis-initramfs
    - vim-tiny
    - iputils-ping
    - less
  late-commands:
    - curl -L https://skyc2.github.io/autoinstall/extra/initramfs-sslcerts -O /usr/share/initramfs-tools/hooks/sslcerts
    - chmod 755 /usr/share/initramfs-tools/hooks/sslcerts
    - update-initramfs -u -k all
EOC
}

append_cft() {
  cat <<EOC >> "$OUTFILE"
    - sudo mkdir -p --mode=0755 /usr/share/keyrings
    - curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    - echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
    - sudo apt update && sudo apt install cloudflared -y
    - sudo cloudflared service install ${CFTTOKEN}
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
--cft-token <cloudflare-tunnel-token> set cloudflare tunnel token
--output <output_dir> set output directory (default ./deploy/<hostname>)
EOU
  exit
}

while [ $# -gt 0 ]; do
  case $1 in
    --host) HOST=$2; shift;;
    --user|-u) USER=$2; shift;;
    --password|-p) PASS=$(echo "$2" | mkpasswd -m sha-512 -s); shift;;
    --source|-s) SRCID=$2; shift;;
    --luks-pw|-e) LUKSPW=$2; shift;;
    --output|-o) OUTDIR=$2; shift;;
    --preset) PRESET=$2; shift;;
    --ssh-key1) SSHK1=$2; shift;;
    --ssh-key2) SSHK2=$2; shift;;
    --cft-token) CFTTOKEN=$2; shift;;
    --help|-h) usage_exit;;
    -*) logerr "Unknown option $1"; usage_exit;;
  esac
  shift
done

OUTDIR=${OUTDIR:-"deploy/$HOST"}
case "$OUTDIR" in
  -) OUTFILE=/dev/stdout;;
  *) mkdir -p "$OUTDIR"
     OUTFILE="$OUTDIR/user-data"
     echo "#empty" > "$OUTDIR/meta-data";;
esac
[ "$OUTDIR" = - ] && OUTDIR=/dev/stdout

gen_"$PRESET"

[ "$CFTTOKEN" ] && append_cft
