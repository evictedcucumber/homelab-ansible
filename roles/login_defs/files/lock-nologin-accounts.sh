#!/usr/bin/env bash
# CIS Debian 13 Benchmark 5.4.2.7 + 5.4.2.8 - reproduced from the benchmark's
# example remediation scripts. Sets service accounts to nologin and locks any
# non-root account that has no valid login shell. Prints one line per change so
# Ansible can key `changed` on output; a compliant host prints nothing.
{
   changed=0
   l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"
   l_uid_min="$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"

   # 5.4.2.7 - system accounts must not have a valid login shell
   while IFS= read -r l_user; do
      echo " - setting nologin shell for service account: ${l_user}"
      usermod -s "$(command -v nologin)" "$l_user"
      changed=1
   done < <(awk -v pat="$l_valid_shells" -F: \
      '($1!~/^(root|halt|sync|shutdown|nfsnobody)$/ && ($3<'"$l_uid_min"' || $3 == 65534) && $(NF) ~ pat){print $1}' /etc/passwd)

   # 5.4.2.8 - non-root accounts without a valid login shell must be locked
   while IFS= read -r l_user; do
      if passwd -S "$l_user" | awk '$2 !~ /^L/{exit 0} {exit 1}'; then
         echo " - locking account without a valid shell: ${l_user}"
         usermod -L "$l_user"
         changed=1
      fi
   done < <(awk -v pat="$l_valid_shells" -F: '($1 != "root" && $(NF) !~ pat){print $1}' /etc/passwd)

   [ "$changed" -eq 0 ] && echo "ok - all service accounts nologin and locked"
}
exit 0
