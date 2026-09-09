# kernel_modules

Unloads and deny-lists kernel modules a hardened server does not need: for each
entry it runs `modprobe -r` and writes an `/etc/modprobe.d` drop-in with
`install <mod> /bin/false` + `blacklist <mod>`.

Covers CIS Debian 13 §1.1.1 (filesystem modules) and §3.2 (network modules).
`overlay` is intentionally left loadable — container/overlayfs workloads (LXC on
Proxmox) need it.

The set lives in `kernel_modules_blacklist` (`defaults/main.yml`); override it
per platform. Every entry is applied; each carries a `level` key for reference
(squashfs and udf are the Level 2 ones).
