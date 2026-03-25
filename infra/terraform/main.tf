locals {
  name_prefix = "${var.project_name}-${var.environment}"
  tags        = [var.project_name, var.environment, "tak"]
}

module "droplet" {
  source              = "./modules/droplet"
  name                = "${local.name_prefix}-server"
  region              = var.region
  droplet_size        = var.droplet_size
  ssh_key_fingerprint = var.ssh_key_fingerprint
  tags                = local.tags
  vpc_uuid            = var.vpc_uuid
}

module "volume" {
  source      = "./modules/volume"
  name        = "${local.name_prefix}-data"
  region      = var.region
  size        = var.volume_size_gib
  droplet_id  = module.droplet.id
  filesystem  = "ext4"
  description = "Persistent data volume for TAK pilot"
}

module "firewall" {
  source                = "./modules/firewall"
  name                  = "${local.name_prefix}-fw"
  droplet_ids           = [module.droplet.id]
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
}

module "dns" {
  count      = var.enable_dns ? 1 : 0
  source     = "./modules/dns"
  domain     = var.domain
  subdomain  = var.subdomain
  ip_address = module.droplet.ipv4
}
