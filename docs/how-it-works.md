# How it works

This [GCP Kubernetes Application](./kubernetes-app.md) works by creating a Kubernetes App manifest that deploys the Elastic Agent in Fleet Managed mode in your GKE cluster.

Deployment happens by running the [`deployer`](./deployer.md) image.

Once the Job is completed the application is running in the configured namespace.