**This is experimental and not yet available through GCP Marketplace**

# GCP Kubernetes App for Elastic Agent

[GCP Kubernetes App] are pre-packaged application that can be run in a Kubernetes cluster. GCP console allows installing them via a simplified procedure (GUI or CLI based) and they can potentially be sold in the GCP Marketplace. However, our listing of Elastic Agent as a Kubernetes App would be free.

Is possible to install this application in [non-GKE clusters too].

[GCP Kubernetes App]: https://cloud.google.com/marketplace/docs/partners/kubernetes
[non-GKE clusters too]: ttps://cloud.google.com/marketplace/docs/kubernetes-apps/deploying-non-gke-clusters

## Versions

Each Elastic Agent version requires some configuration to be made available as a GCP Kubernetes App. The current available versions are:

- `7.17` release track backed by `7.17.5`
- `8.3` release track backed by `8.3.3` (recommended)
