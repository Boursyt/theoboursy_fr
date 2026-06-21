output "service_urls" {
  description = "Default run.app URL per Cloud Run service."
  value       = { for k, s in google_cloud_run_v2_service.app : k => s.uri }
}

output "mapped_domains" {
  description = "Custom domains mapped to each service."
  value       = { for k, b in local.domain_bindings : k => b.app }
}