# bootloader

GRUB2 hardening: kernel command-line additions (via an `/etc/default/grub.d`
drop-in), an optional bootloader password, and `root:root 0600` on the generated
`grub.cfg`.

Covers CIS Debian 13 §1.4. Other roles extend the kernel command line through
`bootloader_cmdline_extra` / `bootloader_cmdline_default_extra`.

`update-grub` runs as an explicit task at the end of the role, not a handler: a
deduped cross-role `Update grub` handler was flushing *after* the reboot (which
is defined in this role and shared with `filesystem_mounts`), so the box rebooted
before grub was rebuilt. Roles that add their own drop-in later in the play
(`auditd`) regenerate grub themselves the same way. A broken drop-in now fails
the run at this role instead of silently.

The password is opt-in: set a vaulted `bootloader_password_hash` (from
`grub-mkpasswd-pbkdf2 --iteration-count=600000`). The role keeps `--unrestricted`
on the generated menuentries so the default entry still boots unattended — the
password only guards interactive edit / the GRUB shell. While the hash is empty
the role warns; set `bootloader_require_password: true` (e.g. in prod
`host_vars`) to make an unset hash a hard failure once it is vaulted.
