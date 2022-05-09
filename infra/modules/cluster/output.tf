output "name" {
  value = google_container_cluster.test.name
}

output "compute_zone" {
  value = google_container_cluster.test.location
}