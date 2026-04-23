# tak-ops

Production-minded operations/infrastructure repository for deploying and operating a **pilot Tactical Awareness Kit (TAK)** environment.

## Scope
This repository is designed for a small pilot with:
1. A cloud-hosted TAK server stack on DigitalOcean (Ubuntu 22.04 baseline).
2. A Raspberry Pi edge node for degraded/offline local operations.
3. Operator tooling for validation, smoke tests, backup/restore, and report data preparation.

It intentionally does **not** vendor proprietary/restricted TAK binaries.

---

## Current TAK 5.7 deployment status (checkpoint: 2026-04-12)

Current field state (Ubuntu 24.04 DigitalOcean droplet, package deployment under `/opt/tak`) is **MVP demo-ready baseline**:
- Core listener ports confirmed up: `8443` (HTTPS), `8446` (cert HTTPS), `8089` (TLS ingest).
- PostgreSQL 15 cluster is online and reachable by TAK repository user (`martiuser` to `cot`).
- TAK keystore/truststore artifacts are present and readable by runtime user.
- Remaining warnings are non-blocking for MVP client connectivity testing (see below).

### Service architecture note (important)
TAK runtime here is a **multi-service stack** orchestrated by `/etc/init.d/takserver`, not a single monolith. Wrapper service status can look healthy while individual subservices are unhealthy or partially started. Always validate per-service logs and socket bindings.

### Major issues encountered and resolved (summary)
- PostgreSQL wrapper-service confusion: `systemctl status postgresql` was insufficient; `pg_lsclusters` exposed actual cluster-down state.
- PostgreSQL on small droplet: memory settings initially prevented cluster startup; reduced memory settings restored service.
- Certificate chain drift: stale CA/private artifacts plus password drift caused misleading TLS failures.
- `CoreConfig.xml` alignment: keystore/truststore passwords had to exactly match cert-generation values.
- Debugging method change: `/opt/tak/logs/*` by component provided reliable signal versus wrapper-level status alone.

### Current non-blocking warnings to track
- TLS is enabled but CRL/OCSP validation is not configured (hardening backlog item).
- Plugin service produced earlier noisy/unstable traces and should be treated carefully during MVP demos.

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

## Pilot transport profile assumptions
- Administrative access: SSH TCP/22 (configurable with Terraform `admin_ports`).
- Public entry point: HTTPS reverse proxy on TCP/443 (configurable with Terraform `service_ports`).
- Backend/pilot placeholder service: TCP/8089 (configurable with Terraform `service_ports`).

These defaults are pilot-friendly scaffolding and should be narrowed for production deployment policy.

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
3. **Configure cloud host with Ansible (`tak_servers`)**
   - `ANSIBLE_CONFIG=infra/ansible/ansible.cfg ansible-playbook -i infra/ansible/inventories/dev/hosts.yml infra/ansible/playbooks/site.yml`
4. **Install restricted TAK components (manual handoff)**
   - Follow `docs/deployment-plan.md` and vendor instructions.
5. **Run validation and smoke tests**
   - `./scripts/smoke-test.sh --target <fqdn-or-ip>`
   - Verify backup with `./scripts/backup.sh` and restore with staging default: `./scripts/restore.sh --archive <archive.tar.gz>`
6. **Prepare edge node (`edge_nodes`)**
   - `ANSIBLE_CONFIG=infra/ansible/ansible.cfg ansible-playbook -i infra/ansible/inventories/dev/hosts.yml infra/ansible/playbooks/edge-node.yml`
7. **Promote to prod**
   - Repeat steps using `infra/terraform/environments/prod` and prod inventory.

---

## Tooling dependencies
- Python 3.11+
- `pytest`
- `PyYAML` (required by `scripts/validate-config.sh`)
- `terraform`
- `ansible`
- Shell utilities used by scripts (`curl`, `timeout`, `sha256sum`, `tar`)

`make init` installs Python dependencies (`pytest`, `PyYAML`) for local validation.

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
make terraform-validate
make ansible-lint
make test
```

## Shell script syntax checks (docs/CI note)
- Run `bash -n scripts/*.sh` to catch shell syntax errors early.
- `make lint` already includes this check, so any CI runner invoking `make lint` will enforce shell syntax validation.

## Known limitations
- This repo does not redistribute restricted TAK components.
- Some install/integration steps remain manual by design.
- Pilot-first defaults should be hardened before large-scale production use.

## License
MIT.
