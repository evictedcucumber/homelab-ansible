# filesystem_mounts

Manages `/dev/shm` as a hardened tmpfs and asserts the host's separate
partitions exist with hardened mount options (`nodev` / `nosuid` / `noexec` per
the CIS policy).

Covers CIS Debian 13 §1.1.2. The block-device mounts are host-specific — set
`filesystem_mounts_block` per host, e.g.:

```yaml
filesystem_mounts_block:
  - {path: /tmp,           src: /dev/mapper/vg0-tmp,    fstype: ext4}
  - {path: /home,          src: /dev/mapper/vg0-home,   fstype: ext4}
  - {path: /var,           src: /dev/mapper/vg0-var,    fstype: ext4}
  - {path: /var/tmp,       src: /dev/mapper/vg0-vartmp, fstype: ext4}
  - {path: /var/log,       src: /dev/mapper/vg0-varlog, fstype: ext4}
  - {path: /var/log/audit, src: /dev/mapper/vg0-audit,  fstype: ext4}
```

`opts` is optional per entry; when omitted it comes from
`filesystem_mounts_policy[path]`.
