**This product is available through the GCP Marketplace: go to [Elastic Agent for GKE ](https://console.cloud.google.com/marketplace/product/elastic-prod/elastic-agent)**

# GCP Kubernetes App for Elastic Agent

[GCP Kubernetes App][1] are pre-packaged application that can be run in a Kubernetes cluster. GCP console allows installing them via a simplified procedure (GUI or CLI based) and they can potentially be sold in the GCP Marketplace. However, our listing of Elastic Agent as a Kubernetes App would be free.

Is possible to install this application in [non-GKE clusters too][2].

[1]: https://cloud.google.com/marketplace/docs/partners/kubernetes
[2]: ttps://cloud.google.com/marketplace/docs/kubernetes-apps/deploying-non-gke-clusters

## Versions

Each Elastic Agent version requires some configuration to be made available as a GCP Kubernetes App. The current available versions are:

| Release track | Version  |Recommended
|---------------|----------|--|
| `7.17`        | `7.17.5` ||
| `8.3`         | `8.3.3`  ||
| `8.4`         | `8.4.1`  ||
| `8.5`         | `8.5.0`  ||
| `8.17`        | `8.17.0` |✔|

## Documentation

- [How it works](./docs/how-it-works.md)
- [Installation](./docs/installation.md)
- [Next steps](./docs/next-steps.md)
- [Upgrading the application](./docs/upgrading.md)
- [Removing the application](./docs/deleting.md)

If you are contributing to this repository this documentation dives into more technical details:

- [CONTRIBUTING guidelines](./CONTRIBUTING.md)
- [Kubernetes App](./docs/kubernetes-app.md)
- [Deployer](./docs/deployer.md)
- [App schema](./docs/schema.md)
- [GCP Container Registry structure](./docs/registry-structure.md)
- [Checking images](./docs/checking-images.md)
