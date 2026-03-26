# Runbook: First Deploy

1. Prepare `.env` and inventories (`tak_servers` + `edge_nodes`).
2. Run Terraform apply (dev).
3. Run Ansible `site.yml` for `tak_servers`.
4. **Manual operator step**: install restricted TAK components.
5. Run post-install validation (`scripts/post-install-validate.sh`).
6. Run layered smoke tests (`scripts/smoke-test.sh`).
7. Run edge playbook for `edge_nodes`.
