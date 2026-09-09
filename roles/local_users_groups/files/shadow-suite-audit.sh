#!/usr/bin/env bash
# CIS Debian 13 Benchmark - account-database checks that pair with the shadow
# password-suite settings applied by the login_defs role:
#   5.4.2.1  root is the only UID 0 account
#   5.4.1.6  no account's last password-change date is in the future
# Prints "** PASS **" or "** FAIL **" plus the offending entries.
{
    a_out=()

    while IFS=: read -r l_user _ l_uid _; do
        [ "$l_uid" = "0" ] && [ "$l_user" != "root" ] &&
            a_out+=("  - UID 0 account other than root: \"$l_user\"")
    done </etc/passwd

    l_today="$(($(date -u +%s) / 86400))"
    while IFS=: read -r l_user _ l_last _; do
        [[ "$l_last" =~ ^[0-9]+$ ]] || continue
        [ "$l_last" -gt "$l_today" ] &&
            a_out+=("  - \"$l_user\" last changed password in the future (day $l_last > $l_today)")
    done </etc/shadow

    if [ "${#a_out[@]}" -eq 0 ]; then
        printf '%s\n' "- Audit Result: ** PASS **"
    else
        printf '%s\n' "- Audit Result: ** FAIL **" "${a_out[@]}"
    fi
}
