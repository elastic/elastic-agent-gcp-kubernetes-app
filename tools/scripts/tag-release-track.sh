#!/usr/bin/env bash

set -eou pipefail
[ -n "${DEBUG:-}" ] && set -x

# shellcheck source=./_lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

# Allow overriding GCR location
GCP_GCR="${GCP_GCR:-gcr.io}"

checkvar "GCP_PROJECT_ID" "the GCP project where to move Elastic Agent Docker images"
checkvar "ELASTIC_AGENT_VERSION" "the version of the Elastic Agent Docker image to move to GCP_PROJECT_ID"

gcr_elastic_agent_image="$GCP_GCR/$GCP_PROJECT_ID/elastic-agent"
gcr_deployer_image="$GCP_GCR/$GCP_PROJECT_ID/elastic-agent/deployer"

if [[ $ELASTIC_AGENT_VERSION =~ ^[0-9]+\.[0-9]+ ]]; then
    releaseTrack=${BASH_REMATCH[0]}
    echo "Identified release track: $releaseTrack"

    version=$(get_current_version)
    echo "Tagging $version as latest for release $releaseTrack"
    # app image
    docker tag "$gcr_elastic_agent_image:$version" "$gcr_elastic_agent_image:$releaseTrack"
    docker push "$gcr_elastic_agent_image:$releaseTrack"
    # deployer image
    docker tag "$gcr_deployer_image:$version" "$gcr_deployer_image:$releaseTrack"
    docker push "$gcr_deployer_image:$releaseTrack"
else
    >&2 echo "Something is wrong with your version: $ELASTIC_AGENT_VERSION"
    >&2 echo "Cannot extract release track version (X.Y from X.Y.Z)"
    exit 1
fi
