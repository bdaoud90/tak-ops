# Ansible Structure

## Inventory groups
- `tak_servers`: cloud TAK server hosts
- `edge_nodes`: Raspberry Pi or edge fallback hosts

## Config and role resolution
- Use `infra/ansible/ansible.cfg` as the active config.
- `roles_path = roles` resolves to `infra/ansible/roles` when running with that config.
- Do **not** create workaround roles under `playbooks/roles`.

## Playbooks
- `playbooks/site.yml` - applies server roles to `tak_servers`
- `playbooks/edge-node.yml` - applies edge baseline to `edge_nodes`

## Roles
- `base_bootstrap` - baseline package install and required TAK directory scaffolding
- `hardening` - basic SSH controls
- `reverse_proxy_tls` - nginx + TLS scaffold
- `backup` - backup directory and scheduled task
- `tak_server_placeholder` - explicit manual handoff for restricted TAK install
- `edge_node` - Raspberry Pi edge baseline

## Usage
```bash
ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
  ansible-playbook --syntax-check -i inventories/dev/hosts.yml playbooks/site.yml

ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
  ansible-playbook -i inventories/dev/hosts.yml playbooks/site.yml
```

## Manual boundaries
- `base_bootstrap` prepares host baseline and directories only.
- Manual operator step: install restricted TAK components from authorized artifacts.
