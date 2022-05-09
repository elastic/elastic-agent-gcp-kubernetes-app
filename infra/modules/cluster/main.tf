# GKE cluster
resource "google_container_cluster" "test" {
  name = "${var.name}-test"
  
  initial_node_count = 1
}
