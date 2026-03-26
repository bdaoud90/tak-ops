# Terraform Environment: dev

Pilot development environment.

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
- TODO: replace placeholder values in `terraform.tfvars` with operator-specific values.
- Keep `do_token` out of source control.
