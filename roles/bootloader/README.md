# bootloader

GRUB2 hardening: kernel command-line additions (via an `/etc/default/grub.d`
drop-in), an optional bootloader password, and `root:root 0600` on the generated
`grub.cfg`.

Covers CIS Debian 13 §1.4. Other roles extend the kernel command line through
`bootloader_cmdline_extra` / `bootloader_cmdline_default_extra`.

The password is opt-in: set a vaulted `bootloader_password_hash` (from
`grub-mkpasswd-pbkdf2 --iteration-count=600000`). The role keeps `--unrestricted`
on the generated menuentries so the default entry still boots unattended — the
password only guards interactive edit / the GRUB shell.
