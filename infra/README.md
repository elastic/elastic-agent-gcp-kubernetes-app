This folder contains infrastructure definition to properly offer Elastic Agent as a [GCP Kubernetes App].

Each GCP project in use has it's own folder. The `modules/` folder is used for shared functionalities.

# First run

When you first apply the terraform configuration you will also need to configure `kubectl`. To do this, go into the infrastructure folder and run `gcloud container clusters get-credentials $CLOUDSDK_CONTAINER_CLUSTER`.
`CLOUDSDK_CONTAINER_CLUSTER` variable should contain the cluster name (it does if you're using `direnv` and auto loading the `.envrc`, otherwise set it manually to the output of `terraform output --raw name`).

[GCP Kubernetes App]: https://cloud.google.com/marketplace/docs/partners/kubernetes