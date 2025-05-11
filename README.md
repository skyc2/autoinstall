# Subiquity Autoinstall Config Generator

The goal of the project is to simplify secure Ubuntu server autoinstall setup.

## Features

Besides the usual server identities (hostname, username, password, and ssh public
keys etc.), the generator supports:

* Full disk encryption (FDE)
* Network based disk decription (NBDE) with https support
* Cloudflare tunnel

## Quick Start

```
curl -fsSL https://skyc2.github.io/autoinstall/autoinstallgen.sh > /tmp/install$$ && \
    sudo install /tmp/install$$ /usr/local/bin/autoinstallgen
```
### Just the yaml

```
autoinstallgen -o -
```

prints the default autoinstall yaml to standard output.

### Cloud config layout

```
autoinstallgen
```

generates the default deploy/user-data and meta-data for remote/qemu autoinstall


## User Guide

```
autoinstallgen --help
Usage: autoinstallgen [options]

--host <hostname>     set hostname
--user <username>     set username
--password <password> set user password
--source <source-id>  set source id (ubuntu-server etc.)
--luks-pw <disk-encryption-passphrase> set full disk encryption passphrase
--cft-token <cloudflare-tunnel-token> set cloudflare tunnel token
--ssh-keys <ssh-pub-key,...> set ssh public keys for the user
--tang-url <tang-server-url> set tang server url
--output <output_dir> set output directory (default ./deploy/<hostname>)

```

### Examples

### Ubuntu server minimal with FDE
```
autoinstallgen --host <myhost> --user <myuser> --ssh-keys <key1>,<key2>

```

### FDE, NBDE, and Cloudflare
```
autoinstallgen --host <myhost> --user <myuser> --ssh-keys <key1>,<key2> \
    --tang-url <my-tang-server-url> \
    --cft-token <my-cloudflare-tunnel-token>
```
