This folder contains infrastructure definition to properly serve GCP Kubernetes Application.

Each GCP project in use has it's own folder. The `modules/` folder is used for shared functionalities.

`elastic-obs-integrations-dev` is the testing project, owned by the Obs Cloud Monitoring team.  

`prod-elastic-cloud-billing` is the production project, owned by ??.

# First run

When you first apply the terraform configuration you will also need to configure `kubectl`. To do this, go into the infrastructure folder and run `gcloud container clusters get-credentials $CLOUDSDK_CONTAINER_CLUSTER`.
`CLOUDSDK_CONTAINER_CLUSTER` variable should contain the cluster name (it does if you're using `direnv` and auto loading the `.envrc`, otherwise set it manually to the output of `terraform output --raw name`).