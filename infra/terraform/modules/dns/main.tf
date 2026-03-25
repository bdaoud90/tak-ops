variable "domain" { type = string }
variable "subdomain" { type = string }
variable "ip_address" { type = string }

resource "digitalocean_record" "tak" {
  domain = var.domain
  type   = "A"
  name   = var.subdomain
  value  = var.ip_address
  ttl    = 300
}
