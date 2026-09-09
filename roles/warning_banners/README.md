# warning_banners

Writes `/etc/motd`, `/etc/issue` and `/etc/issue.net` with a site-policy banner
and fixes their `root:root 0644` permissions. Before writing, it asserts the text
carries no mingetty escapes (`\m \r \s \v`) and no distribution name, matching
the CIS audit.

Covers CIS Debian 13 §1.6. Set the text with `warning_banners_text` (per-file
overrides available). `ssh_server` points `Banner` at `/etc/issue.net`.
