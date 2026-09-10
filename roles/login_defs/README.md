# login_defs

Ships `/etc/login.defs`, `/etc/default/useradd`, the root shell environment
(`umask 027`) and `/etc/profile.d` drop-ins for the shell timeout and default
umask; verifies root has a password or is locked and that root's PATH is sane;
sets service accounts to `nologin` and locks any shell-less account.

Covers CIS Debian 13 §5.4 (the shadow password suite and the user default
environment). The policy values live in the vendored files under `files/`.

If `login_defs_root_password_hash` is set (a vaulted yescrypt hash from
`mkpasswd -m yescrypt`, defaulting to the `root_password_hash` vault key), the
role re-applies it to root so a hash predating the `ENCRYPT_METHOD YESCRYPT`
switch is rewritten as `$y$` - otherwise 5.4.1.4 / Lynis AUTH-9229 stay red
until someone runs `passwd` by hand. The apply is idempotent (the `user` module
only rewrites `/etc/shadow` when the hash differs).
