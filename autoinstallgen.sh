#!/bin/bash

SELF=${0##*/}

# defaults
USER=ubuntu
HOST=ubuntu
PASS=$(echo ubuntu | mkpasswd -m sha-512 -s)
SRCID="ubuntu-server-minimal"
LUKSPW="ChangeMeAFTERInstallation!"
PRESET=lvm_luks
SSHKEYS=(
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2yM/uVAf4HQQ4xxs6nMuU3Fjkd9OOSUKOkqPLbuJt5 xps"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBWL+1W3ds8rtQOXxkhFjvgEzPttRwecbhYruhgtcXJ mas"
)


# shell array/list to json array
jsonl() {
  joined=$(IFS= printf ',"%s"' "$@")
  echo ["${joined:1}"]
}

# preset lvm_luks
gen_lvm_luks() {
  cat <<EOC > "$OUTFILE"
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ${HOST}
    username: ${USER}
    password: "${PASS}"
  user-data:
    users:
      - name: ${USER}
        sudo: ALL=(ALL:ALL) NOPASSWD:ALL
  source:
    id: ${SRCID}
  ssh:
    install-server: true
    authorized-keys: $(jsonl "${SSHKEYS[@]}")
  storage:
    layout:
      name: lvm
      password: "${LUKSPW}"
  packages:
    - clevis-luks
    - clevis-initramfs
    - iputils-ping
    - less
    - vim-tiny
  late-commands:
    - curl -fsSL https://skyc2.github.io/autoinstall/extra/initramfs-sslcerts > /target/usr/share/initramfs-tools/hooks/sslcerts
    - chmod 755 /target/usr/share/initramfs-tools/hooks/sslcerts
    - curtin in-target -- update-initramfs -u -k all
EOC
}

append_cft() {
  cat <<EOC >> "$OUTFILE"
    - mkdir -p --mode=0755 /target/usr/share/keyrings
    - curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /target/usr/share/keyrings/cloudflare-main.gpg >/dev/null
    - echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /target/etc/apt/sources.list.d/cloudflared.list
    - curtin in-target -- apt update
    - curtin in-target -- apt install cloudflared -y
    - curtin in-target -- cloudflared service install ${CFTTOKEN}
EOC
}

append_tang() {
  cat <<EOC >> "$OUTFILE"
    - curl -fsSL https://skyc2.github.io/autoinstall/extra/bindtang.sh > /target/tmp/bindtang.sh
    - curtin in-target -- sh /tmp/bindtang.sh "${TANGURL}" "${LUKSPW}"
EOC
}

logerr() {
  echo "$(date -Iseconds): ERROR: $*" >&2
}

usage_exit() {
  cat <<EOU
Usage: $SELF [options]

--host <hostname>     set hostname
--user <username>     set username
--password <password> set user password
--source <source-id>  set source id (ubuntu-server etc.)
--luks-pw <disk-encryption-passphrase> set full disk encryption passphrase
--ssh-keys <ssh-pub-key,...> set ssh public keys for the user
--cft-token <cloudflare-tunnel-token> set cloudflare tunnel token
--tang-url <tang-server-url> set tang server url
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
    --ssh-keys) IFS=, read -r -a SSHKEYS <<<"$2"; shift;;
    --cft-token) CFTTOKEN=$2; shift;;
    --tang-url) TANGURL=$2; shift;;
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
[ "$TANGURL" ] && append_tang
