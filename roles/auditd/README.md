# auditd

Configures the Linux Auditing System: installs `auditd` + `audispd-plugins`,
adds `audit=1 audit_backlog_limit=` to the kernel command line, writes the data
retention policy (`auditd.conf`), deploys the rule set, and locks down the audit
log, config and tool permissions.

Covers CIS Debian 13 §6.2 (all Level 2).

The rules are split across `rules.d/`: `01-initialize.rules` (`-c`, `-D`, buffer
/ failure-mode) runs first and the stock `audit.rules` is emptied so its
trailing `-D` can't wipe the numbered files; `50-cis.rules` holds the syscall
rules plus file/dir/command watches — each watch target is `stat`ed and only
emitted if it exists, since a rule for a missing path (`/etc/netplan`,
`/var/log/sudo.log` when sudo isn't installed, …) makes `augenrules --load`
fail; `50-privileged.rules` is generated from a live SUID/SGID scan;
`99-finalize.rules` is `-e {{ auditd_finalize_mode }}`.

Two deliberate defaults worth knowing:

- `auditd_finalize_mode` is `1`, not `2` — the rules stay mutable so a later
  Proxmox install can add its own without a reboot. Set it to `2` for full
  §6.2.3.36 compliance.
- `auditd_disk_full_action` is `halt` — the host halts if `/var/log/audit`
  fills. Set it to `single` (also CIS-compliant) if a hard halt is unacceptable
  on a hypervisor.
