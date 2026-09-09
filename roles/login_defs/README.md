# login_defs

Ships `/etc/login.defs`, `/etc/default/useradd`, the root shell environment
(`umask 027`) and `/etc/profile.d` drop-ins for the shell timeout and default
umask; verifies root has a password or is locked and that root's PATH is sane;
sets service accounts to `nologin` and locks any shell-less account.

Covers CIS Debian 13 §5.4 (the shadow password suite and the user default
environment). The policy values live in the vendored files under `files/`.
