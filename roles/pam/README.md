# pam

PAM hardening via Debian's `pam-auth-update` model: keeps the PAM packages
current, enables the `faillock`, `pwquality` and `pwhistory` profiles, and ships
their configuration (`faillock.conf`, `pwquality.conf.d/50-cis.conf`,
`pwhistory.conf`). Also asserts the `pam_unix` line in `common-password` meets
policy.

Covers CIS Debian 13 §5.3. Debian-only — EL uses authselect.
