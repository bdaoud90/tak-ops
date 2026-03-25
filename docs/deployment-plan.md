# Deployment Plan

## Deployment sequence diagram
```mermaid
sequenceDiagram
  participant Op as Operator
  participant TF as Terraform
  participant DO as DigitalOcean
  participant AN as Ansible
  participant TAK as TAK Host
  participant EDGE as Edge Node

  Op->>TF: terraform apply (dev)
  TF->>DO: Provision droplet/firewall/volume/(dns)
  DO-->>Op: Host IP + infra outputs
  Op->>AN: Run site playbook
  AN->>TAK: Bootstrap + hardening + proxy + backup
  Op->>TAK: Manual operator step: install restricted TAK components
  Op->>TAK: Run smoke tests + backup drill
  Op->>AN: Run edge-node playbook
  AN->>EDGE: Configure edge baseline
  Op->>TF: Repeat for prod after pilot validation
```

## Phase 1: Provision baseline
- Configure `.env` from `.env.example`.
- Run Terraform in `infra/terraform/environments/dev`.
- Run Ansible `site.yml` against dev inventory.

## Phase 2: Install TAK components
- **Manual operator step**: Obtain licensed/restricted TAK packages from authorized source.
- **Manual operator step**: Transfer packages to `/opt/tak/manual` on host.
- **Manual operator step**: Perform vendor-approved install and licensing actions.

## Phase 3: Validate and harden
- Run smoke tests.
- Confirm backup and restore dry-run.
- Validate outage-mode SOP and edge node readiness.
- Apply production variables and repeat in prod environment.
