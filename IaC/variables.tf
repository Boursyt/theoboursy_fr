variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "Region for Cloud Run services."
  default     = "europe-west1"
}

variable "domain" {
  type        = string
  description = "Apex domain served by the sites."
  default     = "theoboursy.fr"
}

variable "dns_zone_name" {
  type        = string
  description = "Cloud DNS managed zone resource name."
  default     = "theoboursy-fr"
}

locals {
  # config.json drives which services exist and which domains map to them.
  config = jsondecode(file("${path.module}/config.json"))

  apps = { for a in local.config.apps : a.name => a }

  # One (app, subdomain) pair per custom domain to map.
  domain_bindings = {
    for b in flatten([
      for a in local.config.apps : [
        for sub in a.subdomains : {
          app = a.name
          sub = sub
          # "@" -> apex, otherwise "<sub>.<domain>"
          fqdn    = sub == "@" ? var.domain : "${sub}.${var.domain}"
          is_apex = sub == "@"
        }
      ]
    ]) : b.fqdn => b
  }
}