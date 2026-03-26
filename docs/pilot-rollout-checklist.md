# Pilot Rollout Checklist

## Pre-deployment
- [ ] `.env` created and secrets populated securely.
- [ ] Terraform `dev` tfvars updated with real operator values.
- [ ] Ingress CIDRs restricted to pilot operator ranges.
- [ ] Change record created for pilot rollout.

## Deployment
- [ ] Terraform apply completed successfully.
- [ ] Ansible site playbook completed successfully.
- [ ] **Manual operator step** for restricted TAK component install completed.
- [ ] TLS certificate strategy documented and implemented.

## Validation
- [ ] Smoke test passed.
- [ ] Backup created and restore drill completed.
- [ ] Edge node bootstrap completed.
- [ ] Outage-mode SOP reviewed with pilot operators.

## Go/No-Go
- [ ] Security review complete.
- [ ] Known limitations acknowledged by stakeholders.
- [ ] On-call ownership and escalation paths documented.
