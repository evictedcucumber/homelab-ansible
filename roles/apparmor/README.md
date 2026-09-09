# apparmor

Installs AppArmor, ensures the service is running and `aa-enabled` reports it as
active, and (when `apparmor_enforce_all` is set) puts every profile into enforce
mode.

Covers CIS Debian 13 §1.3.1. The related kernel command-line (`lsm=`) and sysctl
(`kernel.apparmor_restrict_unprivileged_unconfined`) settings live in the
`bootloader` and `sysctl` roles.
