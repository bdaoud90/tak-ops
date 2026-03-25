variable "name" { type = string }
variable "region" { type = string }
variable "size" { type = number }
variable "droplet_id" { type = string }
variable "filesystem" { type = string }
variable "description" { type = string }

resource "digitalocean_volume" "this" {
  region                  = var.region
  name                    = var.name
  size                    = var.size
  initial_filesystem_type = var.filesystem
  description             = var.description
}

resource "digitalocean_volume_attachment" "this" {
  droplet_id = var.droplet_id
  volume_id  = digitalocean_volume.this.id
}
