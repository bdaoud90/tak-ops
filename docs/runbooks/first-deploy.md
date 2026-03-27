# Runbook: First Deploy (Pilot)

## 1) Validate local tooling
```bash
./scripts/create-env.sh
./scripts/validate-config.sh
make lint
make terraform-validate
make ansible-lint
```

## 2) Provision dev infrastructure
```bash
cd infra/terraform/environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## 3) Configure cloud TAK host group (`tak_servers`)
```bash
cd /workspace/tak-ops
ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
ansible-playbook -i infra/ansible/inventories/dev/hosts.yml \
infra/ansible/playbooks/site.yml
```

## 4) Manual TAK install handoff
- **Manual operator step**: install licensed/proprietary TAK components following vendor guidance.
- **Manual operator step**: apply production certificate and trust-chain material.

## 5) Validate service reachability
```bash
./scripts/smoke-test.sh --target <tak-fqdn-or-ip>
```

## 6) Validate backup/restore flow
```bash
./scripts/backup.sh
./scripts/restore.sh --archive <archive-path-from-backup>
```

## 7) Configure edge node group (`edge_nodes`)
```bash
ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
ansible-playbook -i infra/ansible/inventories/dev/hosts.yml \
infra/ansible/playbooks/edge-node.yml
```
