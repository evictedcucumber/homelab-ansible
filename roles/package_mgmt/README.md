# package_mgmt

APT hardening: replaces `sources.list` with deb822 `.sources` files carrying
`Signed-By`, fixes ownership/permissions on the key, credential and source
directories and files, and opts out of weak (Recommends/Suggests) dependencies.
`tasks_from: upgrade.yml` applies a safe upgrade (kept separate so the baseline
doesn't patch on every run).

Covers CIS Debian 13 §1.2.
