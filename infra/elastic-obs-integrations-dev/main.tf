terraform {}

provider "google" {}

module "cluster" {
  source = "../modules/cluster"
}

# NOTE: no need for registry, is already enabled and we don't need Container Scanning at the moment.

output "location" {
  value = module.cluster.compute_zone
}

output "name" {
  value = module.cluster.name
}