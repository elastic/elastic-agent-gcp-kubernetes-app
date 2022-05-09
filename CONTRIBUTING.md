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

To port a new version:
1. Create a folder named with the Elastic Stack version (i.e. `8.1.1`)
   Use the full version.
2. Copy over the files from the latest folder in the same major version and **remove** any `build-id.*` files from it.
3. There are some changes needed:
  1. in `Dockerfile` change `FROM` to the expected version
  2. in `schema.yaml` change `x-google-marketplace.publishedVersion` to the new version
  3. in `schema.yaml` update `x-google-marketplace.publishedVersionMetadata`
4. Prepare environment:
   - set `GCP_PROJECT_ID` to the project id where the image should be pushed
   - set `CLOUDSDK_CONTAINER_CLUSTER`, `CLOUDSDK_COMPUTE_ZONE` and `CLOUDSDK_CORE_PROJECT`
   - (optional) set `GCP_GCR` (default to `gcr.io`) if you want to target a regional registry
   - set `ELASTIC_AGENT_VERSION` env var to the version value
5. Run `./tools/scripts/build.sh` to build and push agent and deployer images
6. Run `./tools/scripts/check.sh` to verify that agent and deployer images are available and correctly tagged
7. Run `./tools/scripts/verify.sh` to verify the agent and deployer images, using a live GKE cluster
8. If this is the latest release for a specific release track, run `./tools/scripts/tag-release-track.sh` to move the release track tag to the latest image. 

# Checking if all expected versions are present

1. Ensure `ELASTIC_AGENT_VERSION` is **not set**
2. Run `./tools/scripts/check.sh`
