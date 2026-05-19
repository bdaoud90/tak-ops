# 04 · Deployment & Operations

- **Validated target: Ubuntu 24.04** (earlier planning baseline: Ubuntu 22.04,
  historical only).
- **Sequence:** prep workstation → Terraform (dev) → Ansible `site.yml` →
  **manual TAK install handoff** → smoke + backup/restore drill → Ansible
  `edge-node.yml` → promote to prod.
- **Port roles:** `8089` primary WinTAK/CivTAK TLS client path; `8443`
  HTTPS/API; `8446` cert-auth HTTPS (alternate).
- **Manual boundary:** restricted/proprietary TAK binaries are **not
  vendored**; they are an operator handoff with vendor-approved install.

Authoritative: [runbooks/deployment.md](../runbooks/deployment.md),
[runbooks/first-deploy.md](../runbooks/first-deploy.md),
[deployment-plan.md](../deployment-plan.md),
[backup-restore.md](../backup-restore.md),
[known-issues.md](../known-issues.md).
