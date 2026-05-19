# Runbook: Deployment (Overview)

A partner-safe deployment overview. This page is an **index**; the
authoritative, step-by-step procedures live in the existing runbooks linked
below (kept as-is to avoid breaking references).

## Validated target

- **Validated current target: Ubuntu 24.04.**
- **Earlier planning baseline: Ubuntu 22.04** (historical context only).

## Deployment sequence (high level)

1. Prep operator workstation — env creation + config validation.
2. Provision cloud baseline (dev first) — Terraform
   (`infra/terraform/environments/dev`).
3. Configure cloud host — Ansible `playbooks/site.yml` (`tak_servers`).
4. **Manual operator handoff** — acquire and install licensed/restricted TAK
   components; provide production certificates. **Restricted/proprietary TAK
   binaries are intentionally not vendored in this repository.**
5. Validate — smoke tests + backup/restore drill.
6. Prepare edge node — Ansible `playbooks/edge-node.yml` (`edge_nodes`).
7. Promote to prod — repeat with the prod environment/inventory.

## Port roles (reference)

- `8089` — primary WinTAK/CivTAK TLS client path (pre-issued client certs).
- `8443` — HTTPS/API/web path.
- `8446` — certificate-auth HTTPS path (alternate validation).

See [known-issues.md](../known-issues.md) and the README "Current TAK 5.7
deployment status" section for current field status and caveats.

## Authoritative references

- [First Deploy (Pilot)](./first-deploy.md)
- [Quickstart: Download, Install, Deploy](./quickstart-download-install-deploy.md)
- [Deployment Plan](../deployment-plan.md)
- [Backup & Restore](../backup-restore.md) ·
  [Incident Recovery](./incident-recovery.md)
- [Edge Node](../edge-node.md) · [Degraded Comms](../degraded-comms.md) ·
  [Outage Mode SOP](../outage-mode-sop.md)
- [Documentation Index](../README.md)

> Deployment uses no CI secrets. Keep real endpoint values, certificates, and
> tokens out of version control — see
> [security-and-data-handling.md](../security-and-data-handling.md).
