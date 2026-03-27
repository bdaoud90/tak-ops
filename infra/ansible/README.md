# Ansible Structure

## Inventories
- `inventories/dev/hosts.yml`
  - `tak_servers`: cloud TAK hosts (placeholder examples)
  - `edge_nodes`: edge node hosts (placeholder examples)
- `inventories/prod/hosts.yml`
  - `tak_servers`: production cloud TAK hosts (placeholder examples)
  - `edge_nodes`: production edge hosts (placeholder examples)

## Playbooks
- `playbooks/site.yml` - Cloud host baseline, hardening, proxy scaffold, backup, TAK placeholder. Targets `tak_servers`.
- `playbooks/edge-node.yml` - Edge node baseline role. Targets `edge_nodes`.

## Roles
- `base_bootstrap` - package/bootstrap prerequisites
- `hardening` - basic SSH controls
- `reverse_proxy_tls` - nginx + TLS scaffold
- `backup` - backup directory and scheduled task scaffold
- `tak_server_placeholder` - explicit manual handoff for restricted TAK install
- `edge_node` - Raspberry Pi edge baseline

## Usage
Always run with the repository Ansible config explicitly set:

```bash
ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
ansible-playbook -i infra/ansible/inventories/dev/hosts.yml \
infra/ansible/playbooks/site.yml

ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
ansible-playbook -i infra/ansible/inventories/dev/hosts.yml \
infra/ansible/playbooks/edge-node.yml
```

## Manual boundaries
- Manual operator step: install licensed/restricted TAK artifacts with vendor-approved procedures.
- Manual operator step: replace placeholder certs and tune proxy/firewall rules for real traffic policy.
