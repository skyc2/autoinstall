# Subiquity autoinstall config tool

## CLI to generate the user-data for cloud autoinstall

```
./autoinstallgen.sh --help
Usage:  [options]

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
