module "stack" {
  source              = "../.."
  do_token            = var.do_token
  region              = var.region
  project_name        = var.project_name
  environment         = "dev"
  droplet_size        = var.droplet_size
  ssh_key_fingerprint = var.ssh_key_fingerprint
  enable_dns          = var.enable_dns
  domain              = var.domain
  subdomain           = var.subdomain
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
  allowed_tcp_ports     = var.allowed_tcp_ports
  allowed_udp_ports     = var.allowed_udp_ports
}

output "droplet_ipv4" {
  value = module.stack.droplet_ipv4
}
