#!/usr/bin/env bash
# CIS Debian 13 Benchmark 7.2.1 - 7.2.8 - local user and group database consistency.
# Each block below is the audit published in the benchmark for one recommendation,
# reproduced as-is; only the surrounding collection/formatting is added. The
# benchmark provides no scripted remediation for these ("analyze the output ... and
# perform the appropriate action"), so this task only reports: any finding prints
# "** FAIL **" with the offending entries and fails the play.
#   7.2.1 accounts in /etc/passwd use shadowed passwords
#   7.2.2 /etc/shadow password fields are not empty
#   7.2.3 all groups in /etc/passwd exist in /etc/group
#   7.2.4 shadow group is empty
#   7.2.5 no duplicate UIDs exist
#   7.2.6 no duplicate GIDs exist
#   7.2.7 no duplicate user names exist
#   7.2.8 no duplicate group names exist
#
# Deviation from the benchmark text: 7.2.7's published audit reads /etc/group (a copy
# of the 7.2.8 check); it is corrected here to /etc/passwd so it checks for duplicate
# *user* names as the recommendation title requires.

{
   a_out=()
   add() { while IFS= read -r l_line; do [ -n "$l_line" ] && a_out+=("$l_line"); done; }

   # 7.2.1 Ensure accounts in /etc/passwd use shadowed passwords
   add < <(awk -F: '($2 != "x"){print "  - User: \"" $1 "\" is not set to shadowed passwords"}' /etc/passwd)

   # 7.2.2 Ensure /etc/shadow password fields are not empty
   add < <(awk -F: '($2 == ""){print "  - " $1 " does not have a password"}' /etc/shadow)

   # 7.2.3 Ensure all groups in /etc/passwd exist in /etc/group
   add < <(
      a_passwd_group_gid=("$(awk -F: '{print $4}' /etc/passwd | sort -u)")
      a_group_gid=("$(awk -F: '{print $3}' /etc/group | sort -u)")
      a_passwd_group_diff=("$(printf '%s\n' "${a_group_gid[@]}" "${a_passwd_group_gid[@]}" | sort | uniq -u)")
      while IFS= read -r l_gid; do
         awk -F: '($4 == '"$l_gid"'){print "  - User: \"" $1 "\" has GID: \"" $4 "\" which does not exist in /etc/group"}' /etc/passwd
      done < <(printf '%s\n' "${a_passwd_group_gid[@]}" "${a_passwd_group_diff[@]}" | sort | uniq -D | uniq)
   )

   # 7.2.4 Ensure shadow group is empty
   l_sgid="$(getent group shadow | awk -F: '{print $3}')"
   add < <(awk -F: '($1 == "shadow") && ($4 != ""){print "  - shadow group has members: \"" $4 "\""}' /etc/group)
   add < <(awk -F: -v gid="$l_sgid" '($4 == gid){print "  - user: \"" $1 "\" has the shadow group as primary group"}' /etc/passwd)

   # 7.2.5 Ensure no duplicate UIDs exist
   add < <(
      while read -r l_count l_uid; do
         [ "$l_count" -gt 1 ] && echo "  - Duplicate UID: \"$l_uid\" Users: \"$(awk -F: '($3 == n){print $1}' n="$l_uid" /etc/passwd | xargs)\""
      done < <(cut -f3 -d":" /etc/passwd | sort -n | uniq -c)
   )

   # 7.2.6 Ensure no duplicate GIDs exist
   add < <(
      while read -r l_count l_gid; do
         [ "$l_count" -gt 1 ] && echo "  - Duplicate GID: \"$l_gid\" Groups: \"$(awk -F: '($3 == n){print $1}' n="$l_gid" /etc/group | xargs)\""
      done < <(cut -f3 -d":" /etc/group | sort -n | uniq -c)
   )

   # 7.2.7 Ensure no duplicate user names exist (see deviation note above)
   add < <(
      while read -r l_count l_user; do
         [ "$l_count" -gt 1 ] && echo "  - Duplicate User: \"$l_user\" Users: \"$(awk -F: '($1 == n){print $1}' n="$l_user" /etc/passwd | xargs)\""
      done < <(cut -f1 -d":" /etc/passwd | sort | uniq -c)
   )

   # 7.2.8 Ensure no duplicate group names exist
   add < <(
      while read -r l_count l_group; do
         [ "$l_count" -gt 1 ] && echo "  - Duplicate Group: \"$l_group\" Groups: \"$(awk -F: '($1 == n){print $1}' n="$l_group" /etc/group | xargs)\""
      done < <(cut -f1 -d":" /etc/group | sort | uniq -c)
   )

   if [ "${#a_out[@]}" -eq 0 ]; then
      printf '%s\n' "" "- Audit Result:" "  ** PASS **" "  - Local user and group database is consistent."
   else
      printf '%s\n' "" "- Audit Result:" "  ** FAIL **" " - * Reasons for audit failure * :" "${a_out[@]}"
   fi
}
