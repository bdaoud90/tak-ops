# Ansible Structure

## Playbooks
- `playbooks/site.yml` - Cloud host baseline, hardening, proxy scaffold, backup, TAK placeholder.
- `playbooks/edge-node.yml` - Edge node baseline role.

## Roles
- `base_bootstrap` - package/bootstrap prerequisites
- `hardening` - basic SSH controls
- `reverse_proxy_tls` - nginx + TLS scaffold
- `backup` - backup directory and scheduled task
- `tak_server_placeholder` - explicit manual handoff for restricted TAK install
- `edge_node` - Raspberry Pi edge baseline

## Usage
```bash
ansible-playbook -i inventories/dev/hosts.yml playbooks/site.yml
ansible-playbook -i inventories/dev/hosts.yml playbooks/edge-node.yml
```

## Manual boundaries
- TODO: inject operator-specific certificates, service configs, and restricted TAK install actions per vendor guidance.
