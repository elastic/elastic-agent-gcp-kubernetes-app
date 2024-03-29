resource "google_project_service" "project" {
  # enabling this API automatically enables GCR scanning
  # this is a requirement for GCP Kubernetes app
  # https://cloud.google.com/marketplace/docs/partners/kubernetes/set-up-environment
  # https://cloud.google.com/container-analysis/docs/controlling-costs?hl=en_US
  service = "containerscanning.googleapis.com"

  disable_dependent_services = false
  # NOTE: this settings will require manual disabling of the API after destroy
  disable_on_destroy = false
}

resource "google_project_service" "registry" {
  service = "containerregistry.googleapis.com"

  disable_dependent_services = false
  # NOTE: this settings will require manual disabling of the API after destroy
  disable_on_destroy = false
}

resource "google_container_registry" "registry" {}