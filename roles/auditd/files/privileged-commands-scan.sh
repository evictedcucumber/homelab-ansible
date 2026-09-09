#!/usr/bin/env bash
# CIS Debian 13 Benchmark 6.2.3.10 - list the SUID/SGID executables on every
# exec- and suid-capable filesystem. Reproduced from the benchmark's audit
# procedure; the auditd role turns the output into
# /etc/audit/rules.d/50-privileged.rules. Prints one absolute path per line.
{
    l_types="$(awk '/nodev/ {print $2}' /proc/filesystems | paste -sd,)"
    while IFS= read -r l_partition; do
        find "$l_partition" -xdev -perm /6000 -type f 2>/dev/null
    done < <(findmnt -n -l -k -it "$l_types" | grep -Pv 'noexec|nosuid' | awk '{print $1}') | sort -u
}
exit 0
