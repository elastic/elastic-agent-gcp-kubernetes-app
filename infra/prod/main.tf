terraform {}

provider "vault" {
  
}

data "vault_generic_secret" "prod" {
  path = "secret/observability-team/gcp-kubernetes-app/elastic-agent-prod"
}

# NOTE: if it's the first time you run this, some GCP APIs are being setup under the hood.
# When you enable a new API (aka `google_project_service`) there is a time frame (in 
# minutes) in which the API is enabled but still not responding correctly. 
# If you get a permission error, ensure all `google_project_service` have been created
# and wait some minutes.
provider "google" {
  project = data.vault_generic_secret.prod.data["gcp_project_id"]
}

module "registry" {
  source = "../modules/registry"
}

module "cluster" {
  source = "../modules/cluster"

  name = "elastic-agent-kubernetes-app"
}

output "gcp_project_id" {
  value = data.vault_generic_secret.prod.data["gcp_project_id"]
  sensitive = true
}

output "location" {
  value = module.cluster.compute_zone
}

output "name" {
  value = module.cluster.name
}