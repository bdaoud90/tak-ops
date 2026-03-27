variable "name" { type = string }
variable "droplet_ids" { type = list(string) }
variable "allowed_ingress_cidrs" { type = list(string) }

variable "admin_ports" {
  type        = list(number)
  description = "Administrative ingress ports (pilot default: SSH)."
  default     = [22]
}

variable "service_ports" {
  type        = list(number)
  description = "Service ingress ports (pilot defaults: HTTPS reverse proxy + TAK placeholder service)."
  default     = [443, 8089]
}

locals {
  inbound_ports = distinct(concat(var.admin_ports, var.service_ports))
}

resource "digitalocean_firewall" "this" {
  name        = var.name
  droplet_ids = var.droplet_ids

  dynamic "inbound_rule" {
    for_each = local.inbound_ports
    content {
      protocol         = "tcp"
      port_range       = tostring(inbound_rule.value)
      source_addresses = var.allowed_ingress_cidrs
    }
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
