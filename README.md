# tak-ops

Operations repository for a **small TAK pilot**:
- 1 cloud TAK server (DigitalOcean, Ubuntu 22.04)
- 1 Raspberry Pi edge node
- 2 user clients for demo validation

This repository is designed to be operationally useful **without** redistributing restricted/proprietary TAK components.

## What is automated
- Terraform for cloud infra (droplet, volume, firewall, optional DNS)
- Ansible for cloud host baseline (`tak_servers`) and edge node baseline (`edge_nodes`)
- Operator scripts for config validation, layered smoke tests, backups/restores, and post-install checks
- CI for shell/python/terraform/ansible validation (with explicit optional-tool handling)

## What remains manual
- **Manual operator step**: acquire/install restricted TAK artifacts
- **Manual operator step**: provide cert/key material and deployment-specific service names
- **Manual operator step**: map placeholder validation checks to actual TAK service/process names

## Inventory model
- `tak_servers` = cloud server(s)
- `edge_nodes` = Raspberry Pi edge nodes

## Deployment order (pilot)
1. Create env file and set secrets.
2. Validate config: `./scripts/validate-config.sh`
3. Provision cloud infra (Terraform dev environment).
4. Configure cloud host: `ansible-playbook ... playbooks/site.yml`
5. **Manual operator step**: install restricted TAK components.
6. Run post-install validation: `./scripts/post-install-validate.sh ...`
7. Run layered smoke test: `./scripts/smoke-test.sh --target <fqdn>`
8. Configure edge node: `ansible-playbook ... playbooks/edge-node.yml`
9. Run lab demo runbook: `docs/runbooks/lab-demo.md`
10. Promote to prod after evidence-backed validation.

## Secrets and sensitive values
- `.env` (ignored by git) for operator/local values.
- Recommended to source sensitive values from secure secret managers in CI/CD.
- Keep private keys and restricted artifacts outside source control.

## Pilot transport profile
Default firewall profile is intentionally narrow:
- TCP: 22, 443, 8089
- UDP: none by default

> Manual operator step: adjust port profile only if explicitly required by your TAK deployment design.

## Safety model for backup/restore
- Backups include checksum files.
- Restore verifies checksum by default.
- Restore defaults to staging path.
- `--live-restore` required for dangerous in-place restore.

## Recommended demo path
Use `docs/runbooks/lab-demo.md` for a concrete 1-cloud + 1-edge + 2-client demonstration flow.

## Key docs
- `docs/architecture.md`
- `docs/deployment-plan.md`
- `docs/edge-node.md`
- `docs/backup-restore.md`
- `docs/runbooks/post-install-validation.md`
- `docs/runbooks/lab-demo.md`

## Limitations
- No fake automation for restricted TAK binaries.
- Manual steps are explicit and required.
