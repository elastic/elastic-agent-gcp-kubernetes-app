# Prerequisites

1. Install [gcloud]
2. Follow [GCP tool prerequisites]; you will also need to create the Application CRD (instruction at the link).
3. Configure [GCP Docker auth helper]
4. To run verification a working and reachable GKE cluster is needed.

[gcloud]: https://cloud.google.com/sdk/docs/install
[GCP tool prerequisites]: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/tool-prerequisites.md
[GCP Docker auth helper]: https://cloud.google.com/container-registry/docs/advanced-authentication

# Key environment variables

`CLOUDSDK_CONTAINER_CLUSTER`: name of a GCP GKE cluster to run tests on
`CLOUDSDK_COMPUTE_ZONE`: GCP zone of the GKE cluster
`CLOUDSDK_CORE_PROJECT`: GCP project ID, should be equal to `GCP_PROJECT_ID`
`GCP_PROJECT_ID`: the GCP Project ID all actions will be performed onto.
`ELASTIC_AGENT_VERSION`: the Elastic Agent version to act upon.

# Enabling debugging information

Set `DEBUG` environment variable to **any** value. When set enables `-x` (instruction print) in BASH.

# Versioning

Each folder containing `agent` and `deployer` image. The application is deployed through a set of Kubernetes CRDs that are added to the `deployer` image. It may be needed to build the `deployer` image multiple times for each stack version. 

To support this use case versioning is in the form of: `X.Y.Z-gke.A`. This version is a Semantic Version compatible string where `X.Y.Z` follows usual Major.Minor.Patch and `-gke.A` is a [build metadata](https://semver.org/#spec-item-10) string where `A` is an incremental number starting at `1` that represent the number of build.

This allow to offer the same Elastic Agent version while patching the Kubernetes CRDs used for deployment.

# Release track

The release track is the `MAJOR.MINOR` version; GCP **requires** that the latest image for a given release track (es `8.1.3` for `8.1`) to be tagged accordingly.

# Porting a new version

This application leverages pre build Elastic Agent docker images.

There are 2 components that are required for each version:
- the application manifest
- the deployer application image

All Elastic stack versions can be found in the [Elastic Release Notes page](https://www.elastic.co/guide/en/fleet/current/release-notes.html).

To port a new version:
1. Create a folder named with the Elastic Stack version (i.e. `8.1.1`). **Use the full version.**
2. Copy over the files from the latest folder in the same major version and **remove** any `build-id.*` files from it.
**Make sure the files are up to date with the upstream manifests** available in the [Elastic Agent Repository](https://github.com/elastic/elastic-agent/tree/main/deploy/kubernetes):
   - note that we are using the managed manifests;
   - `ServiceAccount` resources should not be created as a resource, but should be added to the `schema.yaml` ([see docs](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/schema.md#type-service_account)) due to a security limitation applied by GCP;
   - `Role` and `ClusterRole` resources should be specified as part of the `ServiceAccount` and not as separate resources;
   - the `deployer` image has a dedicated `ServiceAccount` (named `deployerServiceAccount` in `schema.yaml`), with a custom role applied;
3. There are some changes needed to upgrade the template to a new version:
  1. in `Dockerfile` change `FROM` to the expected version
  2. in `schema.yaml` change `x-google-marketplace.publishedVersion` to the new version
  3. in `schema.yaml` update `x-google-marketplace.publishedVersionMetadata`; link to the Elastic Agent release notes and select the appropriate `ReleaseTypes` (1 or more from: `Feature`, `BugFix`, `Security`; use `Security` **only** for critical security patches)
4. Prepare shell environment:
   - set `GCP_PROJECT_ID` to the project id where the image should be pushed
   - set `CLOUDSDK_CONTAINER_CLUSTER`, `CLOUDSDK_COMPUTE_ZONE` and `CLOUDSDK_CORE_PROJECT`
   - (optional) set `GCP_GCR` (default to `gcr.io`) if you want to target a regional registry
   - set `ELASTIC_AGENT_VERSION` env var to the version value
5. Run `./tools/scripts/build.sh` to build and push agent and deployer images;
6. run `./tools/scripts/tag-release-track.sh` to move the release track tag to the latest image; 
7. Run `./tools/scripts/check.sh` to verify that agent and deployer images are available and correctly tagged;
8. Run `./tools/scripts/verify.sh` to verify the agent and deployer images, using a live GKE cluster.

# Checking if all expected versions are present

1. Run `./tools/scripts/check-all.sh`
