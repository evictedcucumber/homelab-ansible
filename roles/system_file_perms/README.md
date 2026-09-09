# system_file_perms

Sets ownership and permissions on the `passwd` / `group` / `shadow` / `gshadow`
family (and their `-` backups, `/etc/shells`, `/etc/security/opasswd`), and runs
the benchmark's verbatim world-writable-files remediation and unowned-files
audit.

Covers CIS Debian 13 §7.1. On Debian the shadow files are group `shadow`
(`system_file_perms_shadow_group`); CIS also permits `root`.
