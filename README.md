# Ansible Homelab

Ansible configuration for a Proxmox/Debian 13 homelab server, focused on the
**CIS Debian Linux 13 Benchmark v1.0.0**. Compliance is measured with the
`cis-audit` tool in the sibling [`cis-benchmark`](../cis-benchmark) repo
(OpenSCAP + SCAP Security Guide, with debian-cis and Lynis as a second opinion).
Recommendations that are deliberately not met, or that the scanner cannot judge
correctly on this setup, are listed with their rationale in that repo's
[`deviations/`](../cis-benchmark/deviations) file.

## Setup

This repo uses a Nix flake to provide `ansible`, `ansible-lint`, and `lefthook`
pinned versions. Enter the dev shell with `direnv allow` (or `nix develop`).

Ansible's vault password is read from key files outside the repo, as
configured in [ansible.cfg](ansible.cfg):

- `/etc/ansible/prod.key` for the `prod` inventory
- `/etc/ansible/test.key` for the `test` inventory

If you're running outside the Nix dev shell, install the required
collections first:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Layout

- `roles/` — one capability-scoped role per functional area (e.g. `ssh_server`,
  `pam`, `sysctl`), each with `defaults/main.yml` for its tunables.
- `playbooks/os_debian_13.yml` — the Debian 13 hardening baseline: a single play
  (`hosts: debian_13`) importing every role in benchmark order, so handlers
  (grub regeneration, service restarts, the reboot) flush once at the end.
- `playbooks/patch_debian_13.yml` — OS patching (CIS 1.2.2.1): apt safe upgrade,
  then a reboot if `/run/reboot-required` exists.
- `playbooks/site.yml` — the entry point: imports the baseline, then patching.
- `playbooks/once-off/change-root-password.yml` — run ad hoc to rotate the root
  password.
- Inventories put each host in a role group (`proxmox`) **and** an OS group
  (`debian_13`); the per-OS playbooks target the OS group.
- `lefthook.yml` gates commits on `yamlfix`, `ansible-lint --profile production`
  and `ansible-config validate` (run commits inside `nix develop`).

## Running

```bash
ansible-playbook -i inventories/test playbooks/site.yml                                   # baseline + patching
ansible-playbook -i inventories/test playbooks/os_debian_13.yml                           # baseline only
ansible-playbook -i inventories/test playbooks/patch_debian_13.yml                        # patching only
ansible-playbook -i inventories/test playbooks/site.yml -l <inventory-host>                 # one host
```

After a run (and the reboot it may trigger), re-audit from the `cis-benchmark`
repo with `nix run . -- -H <alias>`.

Deliberately unmet recommendations (UFW, sudo, `PermitRootLogin no`, rsyslog,
remote journal upload, …) and scanner limitations are documented in the
`cis-benchmark` deviations file, which the audit report uses to show them as
accepted deviations instead of failures.

> **Note:** the `test` inventory has per-host `host_vars` (e.g.
> `filesystem_mounts_block`, the LVM device paths). The `prod` inventory has no
> `host_vars` yet, so roles that need host-specific input (e.g.
> `filesystem_mounts`) will fail against it until those are filled in.
