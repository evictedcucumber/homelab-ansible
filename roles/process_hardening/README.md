# process_hardening

Purges `prelink` and `apport`, sets a hard core-dump size limit for all users,
and configures systemd-coredump to discard cores (`ProcessSizeMax=0`,
`Storage=none`).

Covers the package and core-dump items of CIS Debian 13 §1.5. The sysctl-based
§1.5 parameters (`fs.protected_*`, `kernel.*`) are in the `sysctl` role.
