# ssh_server

Renders a hardened `sshd_config` from `ssh_server_config` (plus the strong-only
cipher / KEX / MAC lists), validated with `sshd -t` before install, and fixes
permissions on `sshd_config.d/*.conf` and the host keys.

Covers CIS Debian 13 §5.1. One deviation: `PermitRootLogin` stays
`prohibit-password` (not `no`) because the Ansible control node authenticates to
the host as root over SSH; root login is key-only and restricted via
`AllowUsers root`. Service name is `ssh` on Debian, `sshd` on EL (`vars/`).

Beyond the benchmark, `MaxAuthTries` (3) and `ClientAliveCountMax` (2) are set
tighter than the CIS ceilings, and `AllowTcpForwarding`/`AllowAgentForwarding`
are pinned `no` explicitly (already implied by `DisableForwarding yes`) so Lynis
`SSH-7408` is clean.
