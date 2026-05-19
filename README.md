# tak-ops

Production-minded operations/infrastructure repository for deploying and operating a **pilot Tactical Awareness Kit (TAK)** environment.

## Scope
This repository is designed for a small pilot with:
1. A cloud-hosted TAK server stack on DigitalOcean (**validated environment: Ubuntu 24.04**; earlier planning baseline was Ubuntu 22.04).
2. A Raspberry Pi edge node for degraded/offline local operations.
3. Operator tooling for validation, smoke tests, backup/restore, and report data preparation.

It intentionally does **not** vendor proprietary/restricted TAK binaries.

> **Note:** The public-facing **incident tracker** (a situational-awareness
> data-visualization tool that tracks settler violence and other incidents
> against West Bank communities, source-reported and ACLED-verified) is a
> **separate web component on the PALSHIELD website**. It is *not* in this
> repository — there is no front-end, GitHub Pages site, or iframe embed here.
> This repo is the infrastructure + ingestion backend that feeds the TAK
> server/map and, downstream, that public tracker.

---

## For reviewers and maintainers (start here)

This README serves three audiences:

- **Internal operator** — deploy and run the pilot: see
  [Exact pilot deployment order](#exact-pilot-deployment-order) and
  `docs/runbooks/`.
- **Developer/maintainer** — extend tooling/IaC and keep CI green: see
  [Validation Commands](#validation-commands) and `docs/wiki/`.
- **External partner reviewer** — assess safe integration points: start at
  [`docs/partner-review.md`](docs/partner-review.md).

### Current State
Pilot, **MVP demo-ready baseline** on Ubuntu 24.04 (validated; earlier
planning baseline was Ubuntu 22.04). Details and field caveats are in
[Current TAK 5.7 deployment status](#current-tak-57-deployment-status-checkpoint-2026-04-12)
and [`docs/known-issues.md`](docs/known-issues.md).

### What Works
- Terraform provisioning (DigitalOcean droplet, firewall, volume, optional DNS).
- Ansible roles (base bootstrap, hardening, reverse-proxy/TLS, backup, edge node).
- Operator scripts (env, config validation, smoke test, backup/restore,
  sanitized operator bundle).
- Python data tooling (ACLED OAuth sync + normalization, CSV→GeoJSON, GeoJSON
  validation, Notion export/normalize) with passing unit tests.
- CI: shell/Python/Terraform/Ansible checks, pytest — **no secrets required**.

### Manual Steps
TAK binary/cert handoff and operator-specific inputs are intentionally manual —
see [Automation boundaries](#automation-boundaries-what-is-automated-vs-manual)
and [Exact pilot deployment order](#exact-pilot-deployment-order).

### Known Gaps
See [Known limitations](#known-limitations), [`docs/known-issues.md`](docs/known-issues.md),
and the phased [`docs/backlog/`](docs/backlog/). Highlights: CRL/OCSP revocation
not yet enabled; Android cert-onboarding SOP not formalized; no media pipeline.

### Validation Commands
```bash
./scripts/create-env.sh
./scripts/validate-config.sh
make lint              # bash -n scripts/*.sh + python compileall + config validation
make test              # pytest
make terraform-validate
make ansible-lint
```

### Partner Integration Points
Buraq AI is being considered for **proposed, not-yet-implemented** AI media
triage (scene/context tagging, damage classification, evidence organization)
with mandatory human review. Boundaries and the proposed data contract are in
[`docs/buraq-ai-integration.md`](docs/buraq-ai-integration.md). Hard rule: no
biometric ID, face recognition, tracking, targeting, or identity inference.

### Do Not Commit
Never commit secrets/tokens, certificates/keys, Terraform state, precise
sensitive coordinates, private server FQDNs/IPs, field or source identities,
operational procedures, licensed/vendor TAK artifacts, or raw sensitive media.
Full rules and redaction guidance:
[`docs/security-and-data-handling.md`](docs/security-and-data-handling.md).

---

## Current TAK 5.7 deployment status (checkpoint: 2026-04-12)

Current field state (Ubuntu 24.04 DigitalOcean droplet, package deployment under `/opt/tak`) is **MVP demo-ready baseline**:
- Core listener ports confirmed up: `8443` (HTTPS/API), `8446` (certificate-auth HTTPS), `8089` (primary WinTAK/CivTAK TLS connection path with pre-issued client certs).
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
- Android clients may fail when system trust assumptions conflict with per-connection client-certificate handling; see runbook for constraints.

### Verified vs Unresolved vs Backlog
**Verified**
- Ubuntu 24.04 is the validated deployment target for current operations.
- `8089` with TLS + pre-issued client certificates is the current primary client test workflow.
- `8443` and `8446` remain documented and active with distinct roles.

**Unresolved**
- Android trust-store and client-cert coexistence behavior remains device/OS-version dependent.
- Plugin subsystem still contributes noise during troubleshooting.

**Backlog**
- Enable CRL/OCSP revocation checking.
- Formalize Android certificate onboarding SOP by device profile.

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
- TAK client workflow:
  - `8089` TLS + pre-issued client cert import is the primary current path for WinTAK/CivTAK enrollment testing.
  - `8446` remains cert-auth HTTPS path for alternate validation scenarios.
  - `8443` remains web/API HTTPS path.

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
```
tak-ops/
├── infra/
│   ├── terraform/        # DigitalOcean modules + dev/prod environments
│   └── ansible/          # playbooks (site, edge-node) + hardening roles
├── scripts/              # operator shell tooling (backup/restore/smoke/etc.)
├── tooling/
│   ├── acled/            # ACLED OAuth sync + normalization
│   ├── geo/              # CSV→GeoJSON, GeoJSON validation
│   └── notion/           # report export/normalization
├── tests/                # pytest (acled transform, geo pipeline)
├── config/               # pilot.yaml (validated by scripts/validate-config.sh)
├── docs/                 # architecture, runbooks, SOPs, schema, wiki, partner docs
│   ├── README.md         #   → documentation index (start here)
│   ├── partner-review.md · data-flow.md · buraq-ai-integration.md
│   ├── security-and-data-handling.md · glossary.md
│   ├── schema/           #   incidents-json.md (in-repo + public contract)
│   ├── runbooks/ · data/ · architecture/ · wiki/ · backlog/
├── .github/              # CI workflow, issue/PR templates, SECURITY.md
├── Makefile · ROADMAP.md · .env.example · .gitignore
```
Full documentation index: [`docs/README.md`](docs/README.md).

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
