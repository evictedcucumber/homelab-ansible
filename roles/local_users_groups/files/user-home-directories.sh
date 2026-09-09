#!/usr/bin/env bash
# CIS Debian 13 Benchmark 7.2.9 - Ensure local interactive user home directories are
# configured. This is the remediation script published in the benchmark, reproduced
# verbatim. For every local interactive user (a user whose login shell appears in
# /etc/shells) it fixes home directory ownership and removes group/other excess
# permissions (target mode 0750). It prints "No modification needed to local
# interactive users home directories" when nothing changed, which Ansible uses to
# decide whether the task reports "changed". A missing home directory is reported
# for manual action per local site policy - it is not created here.

{
   l_output2=""
   l_valid_shells="^($( awk -F\/ '$NF != "nologin" {print}' /etc/shells | sed -rn '/^\//{s,/,\\\\/,g;p}' | paste -s -d '|' - ))$"
   unset a_uarr && a_uarr=() # Clear and initialize array
   while read -r l_epu l_eph; do # Populate array with users and user home location
      a_uarr+=("$l_epu $l_eph")
   done <<< "$(awk -v pat="$l_valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)"
   l_asize="${#a_uarr[@]}" # Here if we want to look at number of users before proceeding
   [ "$l_asize " -gt "10000" ] && echo -e "\n  ** INFO **\n  - \"$l_asize\" Local interactive users found on the system\n  - This may be a long running process\n"
   while read -r l_user l_home; do
      if [ -d "$l_home" ]; then
         l_mask='0027'
         l_max="$( printf '%o' $(( 0777 & ~$l_mask)) )"
         while read -r l_own l_mode; do
            if [ "$l_user" != "$l_own" ]; then
               l_output2="$l_output2\n  - User: \"$l_user\" Home \"$l_home\" is owned by: \"$l_own\"\n  -  changing ownership to: \"$l_user\"\n"
               chown "$l_user" "$l_home"
            fi
            if [ $(( $l_mode & $l_mask )) -gt 0 ]; then
               l_output2="$l_output2\n  - User: \"$l_user\" Home \"$l_home\" is mode: \"$l_mode\" should be mode: \"$l_max\" or more restrictive\n  -  removing excess permissions\n"
               chmod g-w,o-rwx "$l_home"
            fi
         done <<< "$(stat -Lc '%U %#a' "$l_home")"
      else
         l_output2="$l_output2\n  - User: \"$l_user\" Home \"$l_home\" Doesn't exist\n  -  Please create a home in accordance with local site policy"
      fi
   done <<< "$(printf '%s\n' "${a_uarr[@]}")"
   if [ -z "$l_output2" ]; then # If l_output2 is empty, we pass
      echo -e " - No modification needed to local interactive users home directories"
   else
      echo -e "\n$l_output2"
   fi
}

# Change is signalled to Ansible through stdout, not the exit code, so exit success
# explicitly regardless of the trailing command's status.
exit 0
