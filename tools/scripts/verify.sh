#!/usr/bin/env bash

set -eou pipefail
[ -n "${DEBUG:-}" ] && set -x

# shellcheck source=./_lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

# Allow overriding GCR location
GCP_GCR="${GCP_GCR:-gcr.io}"

REGISTRY="$GCP_GCR/$GCP_PROJECT_ID"
APP_NAME="elastic-agent"

if [ -z "${DEPLOYER_VERSION:-}" ]; then
  echo "Calculating deployer version"

  checkvar "ELASTIC_AGENT_VERSION" "the version of the Elastic Agent Docker image to move to GCP_PROJECT_ID"

  DEPLOYER_VERSION=$(get_current_version)
fi

>&2 echo "==> $(tput bold)$REGISTRY/$APP_NAME/deployer:$DEPLOYER_VERSION$(tput sgr0)"

# https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/mpdev-references.md#smoke-test-an-application
mpdev /scripts/verify --deployer="$REGISTRY/$APP_NAME/deployer:$DEPLOYER_VERSION"
