#!/usr/bin/env bash
# CIS Debian 13 Benchmark 7.1.11 - Ensure world writable files and directories are
# secured. This is the remediation script published in the benchmark, reproduced
# verbatim. It removes write permission for "other" from world writable files and
# adds the sticky bit to world writable directories, printing one block per change.
# Ansible keys "changed" on whether any output was produced, so a compliant host
# prints nothing and the task reports "ok".

{
   l_smask='01000'
   a_file=(); a_dir=() # Initialize arrays
   a_path=(! -path "/run/user/*" -a ! -path "/proc/*" -a ! -path "*/containerd/*" -a ! -path "*/kubelet/pods/*" -a ! -path "*/kubelet/plugins/*" -a ! -path "/sys/*" -a ! -path "/snap/*")
   while IFS= read -r l_mount; do
      while IFS= read -r -d $'\0' l_file; do
         if [ -e "$l_file" ]; then
            l_mode="$(stat -Lc '%#a' "$l_file")"
            if [ -f "$l_file" ]; then # Remove excess permissions from WW files
               echo -e " - File: \"$l_file\" is mode: \"$l_mode\"\n  - removing write permission on \"$l_file\" from \"other\""
               chmod o-w "$l_file"
            fi
            if [ -d "$l_file" ]; then # Add sticky bit
               if [ ! $(( $l_mode & $l_smask )) -gt 0 ]; then
                  echo -e " - Directory: \"$l_file\" is mode: \"$l_mode\" and doesn't have the sticky bit set\n  - Adding the sticky bit"
                  chmod a+t "$l_file"
               fi
            fi
         fi
      done < <(find "$l_mount" -xdev \( "${a_path[@]}" \) \( -type f -o -type d \) -perm -0002 -print0 2> /dev/null)
   done < <(findmnt -Dkerno fstype,target | awk '($1 !~ /^\s*(nfs|proc|smb|vfat|iso9660|efivarfs|selinuxfs)/ && $2 !~ /^(\/run\/user\/|\/tmp|\/var\/tmp)/){print $2}')
}

# The verbatim block above ends on a `while` loop whose exit status is undefined.
# Change is signalled to Ansible through stdout, not the exit code, so exit success
# explicitly.
exit 0
