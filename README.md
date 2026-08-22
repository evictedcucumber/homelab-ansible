# Ansible Homelab
My ansible configuration for my proxmox homelab server.

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

## Running

Playbooks target one inventory at a time via `-i`:

```bash
ansible-playbook -i inventories/test playbooks/<playbook>.yml
```

For a brand new host, run in this order:

1. `playbooks/once-off/bootstrap.yml` — installs your SSH public key,
   hardens `sshd`, configures apt sources, and does a full upgrade + reboot.
   Only needs to run once per host.
2. `playbooks/os-debian-13.yml` — grub/kernel-module/filesystem/sysctl/apt
   hardening baseline for Debian 13.
3. `playbooks/proxmox.yml` — Proxmox-specific configuration (firewall,
   fail2ban, the no-subscription-nag patch).

`playbooks/once-off/change-root-password.yml` is run ad hoc, whenever the
root password needs rotating.

> **Note:** the `test` inventory is fully populated (vaulted secrets,
> firewall/fail2ban host vars). The `prod` inventory is currently a stub —
> it has no `group_vars`/`host_vars` yet, so most roles will fail against it
> until those are filled in.
