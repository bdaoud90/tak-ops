# Terraform Environment: dev

Pilot development environment.

## Usage
```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Notes
- TODO: replace placeholder values in `terraform.tfvars` with operator-specific values.
- Keep `do_token` out of source control.
