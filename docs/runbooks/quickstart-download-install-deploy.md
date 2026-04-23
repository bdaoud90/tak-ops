# Runbook: Quickstart (Download, Install, Deploy)

This quickstart is ordered by dependency so each step builds on the previous one.

## 1) Clone or download the repository

```bash
# Option A: clone from your git origin (replace URL)
git clone <git-url> tak-ops
cd tak-ops
```

```bash
# Option B: if already downloaded as an archive
cd /path/to
unzip tak-ops.zip
cd tak-ops
```

## 2) Local bootstrap command and expected output

```bash
./scripts/create-env.sh
cp -n .env.example .env
./scripts/validate-config.sh
```

Expected output pattern:
- `./scripts/create-env.sh` reports local environment scaffolding completion.
- `./scripts/validate-config.sh` exits successfully and reports configuration as valid.

## 3) Terraform init/plan/apply path

```bash
cd infra/terraform/environments/dev
cp -n terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
cd /workspace/tak-ops
```

## 4) Ansible inventory + playbook path

```bash
# review inventory first
sed -n '1,200p' infra/ansible/inventories/dev/hosts.yml

# configure tak_servers baseline
ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
ansible-playbook -i infra/ansible/inventories/dev/hosts.yml \
infra/ansible/playbooks/site.yml

# configure edge_nodes baseline
ANSIBLE_CONFIG=infra/ansible/ansible.cfg \
ansible-playbook -i infra/ansible/inventories/dev/hosts.yml \
infra/ansible/playbooks/edge-node.yml
```

## 5) Manual TAK artifact boundary (not automated in this repo)

The following are intentional manual handoff steps and are **not** automated in this repository:
- Acquire licensed/proprietary/restricted TAK artifacts from approved channels.
- Stage artifacts in `TAK_MANUAL_STAGING_DIR` (default `/opt/tak/manual`).
- Run vendor-approved TAK installation and certificate workflows.
- Provide production certificate/trust-chain materials and policy-specific firewall/DNS inputs.

## 6) Post-install validation commands

Run these checks on the deployed TAK host, in this order:

```bash
# 1) PostgreSQL cluster truth check
pg_lsclusters

# 2) listener/port verification for core TAK endpoints
ss -ltnp | rg ':(8089|8443|8446)\b'

# 3) targeted log tails (one command per service)
tail -n 100 /opt/tak/logs/takserver-api.log
tail -n 100 /opt/tak/logs/takserver-messaging.log
tail -n 100 /opt/tak/logs/takserver-retention.log
tail -n 100 /opt/tak/logs/takserver-config.log
tail -n 100 /opt/tak/logs/takserver-plugins.log

# 4) keystore verification (prompts for keystore password)
keytool -list -keystore /opt/tak/certs/files/takserver.jks
```

## 7) Related runbooks and schema docs

- [TAK Demo MVP](./tak-demo-mvp.md)
- [ACLED Ingestion](./acled-ingestion.md)
- [Layer Schema](../data/layer-schema.md)
