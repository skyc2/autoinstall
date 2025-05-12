# Subiquity Autoinstall Config Generator

The goal of the project is to simplify secure Ubuntu server autoinstall setup.

## Features

Besides the usual server identities (hostname, username, password, and ssh public
keys etc.), the generator enables easy setup of:

* Full disk encryption (FDE)
* Network based disk decription (NBDE) with https support
* Cloudflare tunnel

Tested releases:

* Ubuntu 22.04.5 LTS
* Ubuntu 24.04.2 LTS
* Ubuntu 24.10
* Ubuntu 25.04

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

generates the default deploy/ubuntu/user-data and meta-data for remote/qemu autoinstall


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

#### Ubuntu server minimal with FDE
```
autoinstallgen --host <myhost> --user <myuser> --ssh-keys <key1>,<key2>

```

generates cloud config in the ./deploy/<myhost> directory

#### FDE, NBDE, and Cloudflare
```
autoinstallgen --host <myhost> --user <myuser> --ssh-keys <key1>,<key2> \
    --tang-url <my-tang-server-url> \
    --cft-token <my-cloudflare-tunnel-token>
```

### Remote autoinstall using netboot.xyz

Boot [netboot.xyz](https://netboot.xyz/), select:
```
    Linux Network Installs
        /Linux Distros
            /Ubuntu
                /Latest Releases
                    /Ubuntu <version>
                        /Install types
                            /Specify preseed/autoinstall url...

```
and enter: https://skyc2.github.io/autoinstall/deploy/ubuntu
to deploy the example in this repo, which gives me access to your server :)

## Security Reminder!

The default FDE passphrase is "ChangeMeAFTERInstallation!". So change the volume encryption passphrase after the installation!
```
sudo cryptsetup luksChangeKey /dev/vda3 # the backing disk of the root volume, maybe different across platforms.
```

Note, the threat model of FDE here is for data encryption at rest. You should
assume host/hypervisor has full access to the server memory, unless the server
is booted with proper memory encryption setup (TSME with secure boot for
baremetal or SEV-* etc. for VMs)
