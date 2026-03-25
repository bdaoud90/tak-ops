# tak-ops

Production-minded operations/infrastructure repository for deploying and operating a **pilot Tactical Awareness Kit (TAK)** environment.

## Scope
This repository is designed for a small pilot with:
1. A cloud-hosted TAK server stack on DigitalOcean (Ubuntu 22.04 baseline).
2. A Raspberry Pi edge node for degraded/offline local operations.
3. Operator tooling for validation, smoke tests, backup/restore, and report data preparation.

It intentionally does **not** vendor proprietary/restricted TAK binaries.

---

## Automation boundaries (what is automated vs manual)

### Automated provisioning
- Terraform provisioning for DigitalOcean:
  - droplet
  - firewall
  - block volume
  - optional DNS record
- Ansible roles for:
  - base OS bootstrap
  - hardening baseline
  - reverse proxy/TLS scaffolding
  - backup job setup
  - edge node baseline configuration
- Scripted operator helpers:
  - env creation
  - config validation
  - backup/restore wrappers
  - smoke tests

### Manual operator steps
- **Manual operator step**: acquire licensed/proprietary/restricted TAK artifacts from approved source.
- **Manual operator step**: place artifacts in `TAK_MANUAL_STAGING_DIR` (default `/opt/tak/manual`).
- **Manual operator step**: execute vendor-approved install procedures for restricted components.
- **Manual operator step**: provide production-grade certificates and key material if not fully automated through your PKI workflow.
- **Manual operator step**: provide operator-specific firewall source ranges and DNS values.

---

## Secrets and sensitive configuration
- Copy `.env.example` to `.env`.
- Keep `.env` out of source control (already ignored by `.gitignore`).
- Expected secret/sensitive values:
  - `DO_TOKEN`
  - `DO_SSH_KEY_FINGERPRINT`
  - any certificate/private-key material
- Recommended: source secrets from a managed secrets backend in CI/CD and inject at runtime.

---

## Exact pilot deployment order
1. **Prep operator workstation**
   - `./scripts/create-env.sh`
   - Edit `.env` with real values.
   - `./scripts/validate-config.sh`
2. **Provision cloud baseline (dev first)**
   - `cd infra/terraform/environments/dev`
   - `terraform init`
   - `terraform plan -var-file=terraform.tfvars`
   - `terraform apply -var-file=terraform.tfvars`
3. **Configure host with Ansible**
   - `ansible-playbook -i infra/ansible/inventories/dev/hosts.yml infra/ansible/playbooks/site.yml`
4. **Install restricted TAK components (manual handoff)**
   - Follow `docs/deployment-plan.md` and vendor instructions.
5. **Run validation and smoke tests**
   - `./scripts/smoke-test.sh <fqdn-or-ip>`
   - Verify backup with `./scripts/backup.sh` and restore procedure docs.
6. **Prepare edge node**
   - `./scripts/bootstrap-edge.sh --inventory infra/ansible/inventories/dev/hosts.yml`
   - Validate degraded comms SOP.
7. **Promote to prod**
   - Repeat steps using `infra/terraform/environments/prod` and prod inventory.

---

## Safe pilot testing guidance
- Start in `dev` only.
- Restrict ingress CIDRs to trusted operator ranges.
- Use non-production certs/test identities in early dry runs.
- Run smoke tests after each major step (provisioning, config, manual install, restore test).
- Perform at least one backup + restore drill before pilot go-live.
- Record outcomes in runbooks and change logs.

---

## Repository map
- `infra/terraform/` – cloud provisioning modules and environments
- `infra/ansible/` – configuration management playbooks/roles
- `scripts/` – operator shell tooling
- `tooling/` – Python data pipeline helpers
- `docs/` – architecture, runbooks, SOPs
- `.github/` – CI, templates, security policy

## Quickstart
```bash
./scripts/create-env.sh
./scripts/validate-config.sh
make lint
make test
```

## Known limitations
- This repo does not redistribute restricted TAK components.
- Some install/integration steps remain manual by design.
- Pilot-first defaults should be hardened before large-scale production use.

## License
MIT.
