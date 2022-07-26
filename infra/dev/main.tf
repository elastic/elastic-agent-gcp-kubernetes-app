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

# NOTE: no need for registry, is already enabled and we don't need Container Scanning at the moment.

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