# job_schedulers

Hardens cron — unmasks/enables the daemon, locks down `/etc/crontab`, the
`/etc/cron.*` directories and `/etc/cron.allow` / `/etc/cron.deny` — and purges
`at`.

Covers CIS Debian 13 §2.4.
