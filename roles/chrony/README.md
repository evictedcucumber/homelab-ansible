# chrony

Time synchronisation via chrony: installs it, removes competing time daemons so
only one runs, renders `chrony.conf` from `chrony_servers` / `chrony_pools` /
`chrony_directives`, runs the service as the unprivileged `_chrony` user, and
enables it.

Covers CIS Debian 13 §2.3. OS-specific package, service and path names are in
`vars/` (`main.yml` = Debian/Ubuntu, `RedHat.yml` = EL).
