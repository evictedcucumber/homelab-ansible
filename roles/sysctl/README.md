# sysctl

Applies the hardening kernel parameters (device, filesystem, kernel and network)
as `/etc/sysctl.d` drop-ins. Fully data-driven: the nested `sysctl_hardening`
mapping in `defaults/main.yml` is flattened to dotted keys at run time, and the
top-level group (`dev` / `fs` / `kernel` / `net`) selects the target file.

Covers the sysctl-based items of CIS Debian 13 §1.5 (process hardening),
§1.3.1.4 (AppArmor namespace restriction) and §3.3 (network parameters).

Also sets a few keys that Lynis `KRNL-6000` flags but are not CIS controls:
`dev.tty.ldisc_autoload`, `fs.protected_fifos`, `fs.protected_regular`,
`net.core.bpf_jit_harden` and `kernel.unprivileged_bpf_disabled`.

The drop-ins are written as `/etc/sysctl.d/99-cis-*.conf` so they are applied
after systemd's `50-default.conf` — otherwise its `-net.ipv4.conf.all.rp_filter`
line suppresses an earlier `rp_filter=1` at boot (the value then falls back to
the kernel default `0`). Files from the older `20-*` / `60-kernel_sysctl.conf`
layout are deleted first. After applying, the role runs `sysctl --system` and
asserts every managed key holds its expected value (`sysctl_verify_effective`,
default true) so an override fails the run instead of degrading silently.
