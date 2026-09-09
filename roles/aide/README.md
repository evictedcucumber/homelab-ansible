# aide

Filesystem integrity checking with AIDE: installs the packages, drops the audit
tools into the AIDE selection with a SHA-512 checksum, initialises the database,
and enables the daily check timer.

The database is (re)built with `aideinit` when it is missing or when the
audit-tools snippet changes, so the daily check does not report the newly
covered files as spurious drift. Debian 13 removed `update-aide.conf`; `aide`
now reads `aide.conf.d/` directly, so no separate config-compile step is needed.

Covers the CIS Debian 13 §6.3 integrity-checking controls and underpins the
manual §7.1.13 SUID/SGID review (AIDE records binary mode + hash and flags
drift).
