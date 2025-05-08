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
--ssh-key1 <ssh-pub-key-1> set a ssh public key for the user
--ssh-key2 <ssh-pub-key-2> set another public key
--output <output_dir> set output directory (default ./deploy/<hostname>)

```

to see all the options.

