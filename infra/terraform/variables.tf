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
  description = "Ingress CIDRs allowed to reach SSH/HTTPS/TAK ports. TODO: set operator-trusted ranges."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
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

variable "admin_ports" {
  description = "Administrative ingress TCP ports (pilot default: SSH)."
  type        = list(number)
  default     = [22]
}

variable "service_ports" {
  description = "Service ingress TCP ports (pilot defaults: HTTPS reverse proxy and TAK service placeholder)."
  type        = list(number)
  default     = [443, 8089]
}
