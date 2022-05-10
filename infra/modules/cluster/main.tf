# GKE cluster
resource "google_container_cluster" "test" {
  name = "${var.name}-test"

  initial_node_count = 1
}

data "google_client_config" "default" {}

provider "kubectl" {
  host                   = google_container_cluster.test.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.test.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
  load_config_file       = false
}

resource "kubectl_manifest" "external_secrets_cluster_store" {
  # NOTE: this manifest has been generated from upstream App CRD.
  # wget https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml
  yaml_body = file("${path.module}/app-crd.yaml")
}
