# Ansible Structure

## Inventory groups
- `tak_servers`: cloud TAK server hosts
- `edge_nodes`: Raspberry Pi or edge fallback hosts

## Playbooks
- `playbooks/site.yml` - applies server roles to `tak_servers`
- `playbooks/edge-node.yml` - applies edge baseline to `edge_nodes`

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
