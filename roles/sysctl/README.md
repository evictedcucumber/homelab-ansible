# sysctl

Applies the hardening kernel parameters (filesystem, kernel and network) as
`/etc/sysctl.d` drop-ins. Fully data-driven: the nested `sysctl_hardening`
mapping in `defaults/main.yml` is flattened to dotted keys at run time, and the
top-level group (`fs` / `kernel` / `net`) selects the target file.

Covers the sysctl-based items of CIS Debian 13 §1.5 (process hardening),
§1.3.1.4 (AppArmor namespace restriction) and §3.3 (network parameters).
