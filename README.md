# Ansible Homelab

Ansible configuration for a Proxmox/Debian 13 homelab server, focused on the
**CIS Debian Linux 13 Benchmark v1.0.0**. Compliance status per recommendation —
including which are deliberately not implemented and why — lives in the sibling
[`cis-benchmark`](../cis-benchmark) repo. The `homelab-scripts`
[`scripts/cis/cis-coverage.sh`](../scripts/scripts/cis/cis-coverage.sh)
regenerates that repo's `docs/cyclops-debian-13-base/coverage.md` — mapping every
recommendation to the role/tag that implements it — and with `--check` reports
any recommendation marked implemented that has no matching `debian_13_cis_<id>`
tag.

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
  `auditd`, `sysctl`). Each has `defaults/main.yml` for every tunable,
  `vars/<os>.yml` for OS-specific names/paths, and a short `README.md` explaining
  the role and the CIS section it relates to. Every hardening task is tagged
  `cis`, `debian_13_cis`, `debian_13_cis_<id>` and `level1` / `level2` — the
  recommendation IDs are benchmark-namespaced so a role reused for another OS can
  also carry that benchmark's IDs. The authoritative
  recommendation-by-recommendation status is the `cis-benchmark` repo.
- `playbooks/site.yml` — whole-site hardening baseline: imports every
  `os-<os>-<ver>.yml`. `playbooks/patch.yml` — whole-site patching: imports every
  `patch-<os>-<ver>.yml`. These are the normal entry points.
- `playbooks/os-<os>-<ver>.yml` — the hardening baseline for one OS: a single
  play (`hosts: <os-group>` e.g. `debian_13`, `gather_facts: true`) importing
  every role in benchmark order, so their handlers — grub regen, service
  restarts, the reboot — flush once at the end. Idempotent config only — it does
  **not** upgrade the OS. Currently `os-debian-13.yml`.
- `playbooks/patch-<os>-<ver>.yml` — OS patching for that OS (CIS 1.2.2.1), split
  out so the baseline isn't upgrading packages on every run. Currently
  `patch-debian-13.yml` (apt).
- Inventories put each host in a role group (`proxmox`) **and** an OS group
  (`debian_13`); the per-OS playbooks target the OS group.
- `lefthook.yml` gates commits on `ansible-lint --profile production` and
  `ansible-config validate`.

## Running

```bash
ansible-playbook -i inventories/test playbooks/site.yml    # whole-site hardening
ansible-playbook -i inventories/test playbooks/patch.yml   # whole-site patching
```

`patch.yml` only reports a pending reboot by default; pass `-e patch_reboot=true`
to reboot automatically.

Narrow to one OS, host, section or level:

```bash
ansible-playbook -i inventories/test playbooks/os-debian-13.yml
ansible-playbook -i inventories/test playbooks/site.yml -l tcyclops.homelab.zezura.cc
ansible-playbook -i inventories/test playbooks/site.yml --tags debian_13_cis_6.2
ansible-playbook -i inventories/test playbooks/site.yml --skip-tags level2
```

`playbooks/once-off/change-root-password.yml` is run ad hoc, whenever the root
password needs rotating.

Recommendations that are deliberately not implemented (UFW, sudo,
`PermitRootLogin no`, rsyslog, `overlay`, auditd `-e 2`, …) are marked
`:black_circle:` / `:red_circle:` with a rationale in the `cis-benchmark` repo.

> **Note:** the `test` inventory is fully populated (vaulted secrets,
> `filesystem_mounts_block`, firewall/fail2ban host vars). The `prod` inventory is
> currently a stub — it has no `group_vars`/`host_vars` yet, so roles that need
> host-specific input (e.g. `filesystem_mounts`) will fail against it until those
> are filled in.
