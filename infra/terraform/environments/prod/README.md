# Terraform Environment: prod

Pilot production environment.

## Usage
```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Transport profile variables
- `allowed_tcp_ports` defaults to `[22, 443, 8089]`
- `allowed_udp_ports` defaults to `[]`

## Notes
- TODO: set tightened ingress CIDRs for production operators only.
- Use approved change control before apply.
