module "stack" {
  source              = "../.."
  do_token            = var.do_token
  region              = var.region
  project_name        = var.project_name
  environment         = "prod"
  droplet_size        = var.droplet_size
  ssh_key_fingerprint = var.ssh_key_fingerprint
  enable_dns          = var.enable_dns
  domain              = var.domain
  subdomain           = var.subdomain
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
  admin_ports           = var.admin_ports
  service_ports         = var.service_ports
}

output "droplet_ipv4" {
  value = module.stack.droplet_ipv4
}
