# journald

Configures systemd-journald as the client-side logger: persistent + compressed
storage, no syslog forwarding, receive units masked, and rsyslog removed.

Covers CIS Debian 13 §6.1.1. rsyslog (§6.1.2) and journal upload (§6.1.1.2.1–3)
are intentionally not used — there is no central log host.
