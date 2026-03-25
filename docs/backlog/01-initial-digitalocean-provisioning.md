# Title
Initial DigitalOcean provisioning

## Problem
The repository defines Terraform modules and environment scaffolding, but operators need a tracked issue to complete first-pass provisioning with real pilot values and confirm outputs are usable for downstream Ansible configuration.

## Desired outcome
A validated dev deployment on DigitalOcean that creates droplet, firewall, volume, and optional DNS with reproducible Terraform commands.

## Acceptance criteria
- `terraform plan` succeeds in `infra/terraform/environments/dev` with operator values.
- `terraform apply` completes and outputs droplet IP/name.
- Firewall rules reflect pilot-approved ingress CIDRs.
- Volume is attached and visible on instance.
- Runbook notes include exact command transcript and output references.

## Dependencies
- Operator DigitalOcean account and API token.
- Registered SSH key fingerprint.
- Approved CIDR ranges.

## Notes/Risks
- Risk of over-broad ingress if CIDRs remain placeholders.
- DNS should remain optional until domain ownership/process is confirmed.
