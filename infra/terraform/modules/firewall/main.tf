variable "name" {
  description = "Firewall name."
  type        = string
}

variable "droplet_ids" {
  description = "Droplet IDs attached to this firewall."
  type        = list(string)
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to reach configured inbound ports."
  type        = list(string)
}

variable "allowed_tcp_ports" {
  description = "TCP ports exposed for pilot transport profile."
  type        = list(number)
  default     = [22, 443, 8089]
}

variable "allowed_udp_ports" {
  description = "UDP ports exposed for pilot transport profile. Keep empty unless explicitly required."
  type        = list(number)
  default     = []
}

resource "digitalocean_firewall" "this" {
  name        = var.name
  droplet_ids = var.droplet_ids

  dynamic "inbound_rule" {
    for_each = var.allowed_tcp_ports
    content {
      protocol         = "tcp"
      port_range       = tostring(inbound_rule.value)
      source_addresses = var.allowed_ingress_cidrs
    }
  }

  dynamic "inbound_rule" {
    for_each = var.allowed_udp_ports
    content {
      protocol         = "udp"
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
