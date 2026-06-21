# One Cloud Run service per app defined in config.json.
resource "google_cloud_run_v2_service" "app" {
  for_each = local.apps

  name                = each.value.name
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    containers {
      image = each.value.image_url

      ports {
        container_port = 8080
      }

      resources {
        cpu_idle          = true
        startup_cpu_boost = true
        limits = {
          cpu    = "1"
          memory = "128Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }
  }
}

# Public, unauthenticated access (static sites).
resource "google_cloud_run_v2_service_iam_member" "public" {
  for_each = google_cloud_run_v2_service.app

  name     = each.value.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Custom domain mappings (apex + subdomains) -> Cloud Run service.
resource "google_cloud_run_domain_mapping" "app" {
  for_each = local.domain_bindings

  location = var.region
  name     = each.value.fqdn

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.app[each.value.app].name
  }
}