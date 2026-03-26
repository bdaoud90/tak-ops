variable "do_token" {
  description = "DigitalOcean API token. TODO: set via secret manager or environment variable in CI/CD."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region slug (e.g., nyc3)."
  type        = string
}

variable "project_name" {
  description = "Project/resource name prefix."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (dev/prod)."
  type        = string
}

variable "droplet_size" {
  description = "DigitalOcean droplet size slug."
  type        = string
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint of SSH key already registered in DigitalOcean."
  type        = string
}

variable "vpc_uuid" {
  description = "Optional VPC UUID. Leave null to use account default network."
  type        = string
  default     = null
}

variable "volume_size_gib" {
  description = "Size of attached block storage volume in GiB."
  type        = number
  default     = 100
}

variable "allowed_ingress_cidrs" {
  description = "Ingress CIDRs allowed to reach configured pilot transport ports. TODO: set operator-trusted ranges."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}


variable "allowed_tcp_ports" {
  description = "Pilot transport TCP ports to expose on firewall (e.g., SSH/HTTPS/TAK app front door)."
  type        = list(number)
  default     = [22, 443, 8089]
}

variable "allowed_udp_ports" {
  description = "Pilot transport UDP ports to expose. Keep empty unless explicitly required by your deployment profile."
  type        = list(number)
  default     = []
}

variable "enable_dns" {
  description = "Enable managed DNS A record creation."
  type        = bool
  default     = false
}

variable "domain" {
  description = "Existing DNS domain in DigitalOcean. Required if enable_dns=true."
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain label for TAK endpoint (e.g., tak)."
  type        = string
  default     = "tak"
}
