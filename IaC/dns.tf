# Existing managed zone (created by hand).
data "google_dns_managed_zone" "zone" {
  name = var.dns_zone_name
}

# Apex domains -> Google ghs A/AAAA records (Cloud Run custom domain targets).
resource "google_dns_record_set" "apex_a" {
  for_each = { for k, b in local.domain_bindings : k => b if b.is_apex }

  managed_zone = data.google_dns_managed_zone.zone.name
  name         = "${each.value.fqdn}."
  type         = "A"
  ttl          = 300
  rrdatas      = ["216.239.32.21", "216.239.34.21", "216.239.36.21", "216.239.38.21"]
}

resource "google_dns_record_set" "apex_aaaa" {
  for_each = { for k, b in local.domain_bindings : k => b if b.is_apex }

  managed_zone = data.google_dns_managed_zone.zone.name
  name         = "${each.value.fqdn}."
  type         = "AAAA"
  ttl          = 300
  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15",
  ]
}

# Subdomains -> CNAME to Google hosted service.
resource "google_dns_record_set" "sub_cname" {
  for_each = { for k, b in local.domain_bindings : k => b if !b.is_apex }

  managed_zone = data.google_dns_managed_zone.zone.name
  name         = "${each.value.fqdn}."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["ghs.googlehosted.com."]
}