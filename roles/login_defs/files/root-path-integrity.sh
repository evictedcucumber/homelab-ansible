#!/usr/bin/env bash
# CIS Debian 13 Benchmark 5.4.2.5 - Ensure root path integrity. Audit script
# reproduced from the benchmark (no scripted remediation is provided). Prints
# "** PASS **" or "** FAIL **" plus the reasons.
{
   a_output2=() l_pmask="0022"
   l_maxperm="$(printf '%o' $((0777 & ~0022)))"
   l_root_path="$(su - root -c 'env' 2>/dev/null | awk -F= '$1=="PATH"{print $2}')"
   IFS=":" read -ra a_path_loc <<< "$l_root_path"
   grep -q -- "::" <<< "$l_root_path" && a_output2+=(" - root's path contains an empty directory (::)")
   grep -Pq -- ":\h*$" <<< "$l_root_path" && a_output2+=(" - root's path contains a trailing (:)")
   grep -Pq -- '(^\h*|:)\.(:|\h*$)' <<< "$l_root_path" && a_output2+=(" - root's path contains the current working directory (.)")
   for l_path in "${a_path_loc[@]}"; do
      if [ -d "$l_path" ]; then
         while IFS=: read -r l_fmode l_fown; do
            [ "$l_fown" != "root" ] && a_output2+=(" - Directory: \"$l_path\" is owned by: \"$l_fown\" (should be root)")
            [ $((l_fmode & l_pmask)) -gt 0 ] && a_output2+=(" - Directory: \"$l_path\" is mode: \"$l_fmode\" (should be \"$l_maxperm\" or more restrictive)")
         done <<< "$(stat -Lc '%#a:%U' "$l_path")"
      else
         a_output2+=(" - \"$l_path\" is not a directory")
      fi
   done
   if [ "${#a_output2[@]}" -le 0 ]; then
      printf '%s\n' "- Audit Result: ** PASS ** - root's path is correctly configured"
   else
      printf '%s\n' "- Audit Result: ** FAIL **" "${a_output2[@]}"
   fi
}
