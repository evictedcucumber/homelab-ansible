# local_users_groups

Audits the local user and group database for consistency — shadowed passwords,
non-empty password fields, no orphan GIDs, empty `shadow` group, no duplicate
UIDs/GIDs/names, root the only UID 0, all password-change dates in the past — and
fails the run on any finding. Also fixes interactive users' home directories and
dot-file permissions.

Covers CIS Debian 13 §7.2 plus the account-database checks from §5.4.1.6 /
§5.4.2.1–3. The audit/remediation logic is the benchmark's verbatim scripts under
`files/` (with one documented correction: the published §7.2.7 audit reads
`/etc/group`; ours reads `/etc/passwd` for duplicate *user* names).
