variable "name" { type = string }
variable "region" { type = string }
variable "droplet_size" { type = string }
variable "ssh_key_fingerprint" { type = string }
variable "tags" { type = list(string) }
variable "vpc_uuid" {
  type    = string
  default = null
}

resource "digitalocean_droplet" "this" {
  name   = var.name
  region = var.region
  size   = var.droplet_size
  image  = "ubuntu-22-04-x64"
  ssh_keys = [
    var.ssh_key_fingerprint
  ]
  monitoring = true
  tags       = var.tags
  vpc_uuid   = var.vpc_uuid
}

output "id" { value = digitalocean_droplet.this.id }
output "name" { value = digitalocean_droplet.this.name }
output "ipv4" { value = digitalocean_droplet.this.ipv4_address }
