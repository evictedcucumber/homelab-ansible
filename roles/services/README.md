# services

Purges unneeded server and client packages (`services_packages_absent`), masks
the rsync daemon while keeping the `rsync` CLI, binds an installed MTA
(exim4/postfix) to loopback only, and reports listening sockets — failing only
when `services_approved_listening` is set and something unexpected is listening.

Covers CIS Debian 13 §2.1, §2.2, the bluetooth item of §3.1, and the GDM removal
in §1.7.1. Package names are Debian; override `services_packages_absent` for
another distribution.
