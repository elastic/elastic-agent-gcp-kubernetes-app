# Deployer

The `deployer` image is a Docker image that GCP will run in the customer GKE cluster to create all needed resources.

It is run as a [Kubernetes Job].

See [https://cloud.google.com/marketplace/docs/partners/kubernetes/create-app-package#application-images](https://cloud.google.com/marketplace/docs/partners/kubernetes/create-app-package#application-images)


[Kubernetes Job]: https://kubernetes.io/docs/concepts/workloads/controllers/job/