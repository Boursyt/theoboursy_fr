terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # State backend — bucket created by hand (like WIF / AR / SA).
  # bucket + prefix are supplied at `terraform init` via -backend-config (see deploy.yml).
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}