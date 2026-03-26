# Deployment Plan

## Deployment sequence diagram
```mermaid
sequenceDiagram
  participant Op as Operator
  participant TF as Terraform
  participant DO as DigitalOcean
  participant AN as Ansible
  participant TAK as Cloud TAK Host
  participant EDGE as Edge Node
  participant U1 as User Client A
  participant U2 as User Client B

  Op->>TF: Apply dev Terraform
  TF->>DO: Provision droplet/firewall/volume/(optional DNS)
  Op->>AN: Run site.yml on tak_servers
  Op->>TAK: Manual operator step: install restricted TAK components
  Op->>TAK: Run post-install validation + layered smoke tests
  Op->>AN: Run edge-node.yml on edge_nodes
  U1->>TAK: Normal-mode validation
  U2->>TAK: Normal-mode validation
  Op->>EDGE: Run outage drill
  U1->>EDGE: Degraded-mode validation
  U2->>EDGE: Degraded-mode validation
```

## Exact pilot sequence
1. Validate config and environment values.
2. Terraform apply for dev environment.
3. Ansible site playbook on `tak_servers`.
4. **Manual operator step** install restricted TAK components.
5. Run `scripts/post-install-validate.sh` with your service/path checks.
6. Run layered smoke test.
7. Configure edge nodes via Ansible.
8. Execute lab demo runbook (2 clients).
9. Promote to prod only after documented validation evidence.

## Operator notes
- Keep firewall ports minimal; only open what the pilot transport profile requires.
- Do not enable UDP unless your deployment explicitly requires it.
