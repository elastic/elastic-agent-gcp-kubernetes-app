#!/usr/bin/env bash

set -eou pipefail
[ -n "${DEBUG:-}" ] && set -x

# shellcheck source=./_lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

# Allow overriding GCR location
GCP_GCR="${GCP_GCR:-gcr.io}"

checkvar "GCP_PROJECT_ID" "the GCP project where to move Elastic Agent Docker images"
checkvar "ELASTIC_AGENT_VERSION" "the version of the Elastic Agent Docker image to move to GCP_PROJECT_ID"

if [ ! -d "$ELASTIC_AGENT_VERSION" ]; then
  >&2 echo "folder ./$ELASTIC_AGENT_VERSION does not exists"
  exit 1
fi

gcr="$GCP_GCR/$GCP_PROJECT_ID"
tag="$(calculate_next_version)"
gcr_elastic_agent_image="$gcr/elastic-agent:$tag"
gcr_deployer_image="$gcr/elastic-agent/deployer:$tag"

echo "==> Building Google Kubernetes Application $tag from $ELASTIC_AGENT_VERSION/"

pushd "$ELASTIC_AGENT_VERSION"

echo "==> Building Agent image"
docker build -t "$gcr_elastic_agent_image" .
docker push "$gcr_elastic_agent_image"

pushd "deployer"

echo "==> Building Deployer image"
docker build -t "$gcr_deployer_image" .
docker push "$gcr_deployer_image"

popd

popd

write_buildID "$(next_buildID)" > /dev/null

echo "Build app image and deployer version: $tag"