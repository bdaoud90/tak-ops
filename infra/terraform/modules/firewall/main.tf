variable "name" { type = string }
variable "droplet_ids" { type = list(string) }
variable "allowed_ingress_cidrs" { type = list(string) }

resource "digitalocean_firewall" "this" {
  name        = var.name
  droplet_ids = var.droplet_ids

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.allowed_ingress_cidrs
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = var.allowed_ingress_cidrs
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8089"
    source_addresses = var.allowed_ingress_cidrs
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
