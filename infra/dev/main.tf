terraform {}

provider "vault" {
  
}

data "vault_generic_secret" "dev" {
  path = "secret/observability-team/gcp-kubernetes-app/elastic-agent-dev"
}

provider "google" {
  project = data.vault_generic_secret.dev.data["gcp_project_id"]
}

module "cluster" {
  source = "../modules/cluster"
}

# NOTE: no need for registry, is already enabled
resource "google_project_service" "project" {
  # enabling this API automatically enables on demand vulnerability scanning
  # We scan on demand from CI pipelines after building images to prevent possible issues
  # when pushing to the staging repo in production project
  service = "ondemandscanning.googleapis.com"

  disable_dependent_services = false
  # NOTE: this settings will require manual disabling of the API after destroy
  disable_on_destroy = false
}

output "gcp_project_id" {
  value = data.vault_generic_secret.dev.data["gcp_project_id"]
  sensitive = true
}

output "location" {
  value = module.cluster.compute_zone
}

output "name" {
  value = module.cluster.name
}