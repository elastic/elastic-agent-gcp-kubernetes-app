#!/usr/bin/env bash

set -eou pipefail
[ -n "${DEBUG:-}" ] && set -x

# shellcheck source=./_lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

# Allow overriding GCR location
GCP_GCR="${GCP_GCR:-gcr.io}"

checkvar "GCP_PROJECT_ID" "the GCP project where to move Elastic Agent Docker images"

gcr_elastic_agent_image="$GCP_GCR/$GCP_PROJECT_ID/elastic-agent"
gcr_deployer_image="$GCP_GCR/$GCP_PROJECT_ID/elastic-agent/deployer"

agent_tags=$(gcloud container images list-tags "$gcr_elastic_agent_image")
deployer_tags=$(gcloud container images list-tags "$gcr_deployer_image")

check_tag() {
  local tags
  local tag
  tags="$1"
  tag="$2"

  echo "$tags" | grep -F "$tag"
  return $?
}

check_in_tags() {
  local tags
  local tag
  tags="$1"
  tag="$2"

  set +e # it's ok if the next command returns 1 as it signals the tag is not found
  val=$(check_tag "$tags" "$tag")
  ret=$?
  set -e # set -e again to avoid swallowing errors

  if [ ! $ret -eq 0 ]; then
    val=missing
  fi

  echo "$val"
}

err_exit_code=3 # avoid reserved status codes https://tldp.org/LDP/abs/html/exitcodes.html#EXITCODESREF

echo "Checking images in GCP project: $GCP_PROJECT_ID"

if [ -n "${ELASTIC_AGENT_VERSION:-}" ]; then
  >&2 echo "ELASTIC_AGENT_VERSION set, checking $ELASTIC_AGENT_VERSION" 
  v="$(get_current_version)"
  
  agent=$(check_in_tags "$agent_tags" "$v")
  echo "$v agent   : $agent"
  deployer=$(check_in_tags "$deployer_tags" "$v")
  echo "$v deployer: $deployer"

  if [ "$agent" == "missing" ] || [ "$deployer" == "missing" ]; then
    exit $err_exit_code
  fi
else
  >&2 echo "ELASTIC_AGENT_VERSION not set, checking all found versions" 
  
  status=0

  for d in ./7*
  do
    v="$(echo "$d" | cut -d/ -f2 | cut -d- -f2)"
    v="$(ELASTIC_AGENT_VERSION=$v get_current_version)"

    agent=$(check_in_tags "$agent_tags" "$v")
    echo "$v agent   : $agent"
    deployer=$(check_in_tags "$deployer_tags" "$v")
    echo "$v deployer: $deployer"

    if [ "$agent" == "missing" ] || [ "$deployer" == "missing" ]; then
      status=$err_exit_code
    fi
  done
  for d in ./8*
  do
    v="$(echo "$d" | cut -d/ -f2 | cut -d- -f2)"
    v="$(ELASTIC_AGENT_VERSION=$v get_current_version)"

    agent=$(check_in_tags "$agent_tags" "$v")
    echo "$v agent   : $agent"
    deployer=$(check_in_tags "$deployer_tags" "$v")
    echo "$v deployer: $deployer"

    if [ "$agent" == "missing" ] || [ "$deployer" == "missing" ]; then
      status=$err_exit_code
    fi
  done

  if [[ $status -gt 0 ]]; then
    echo "Some image is missing"
  fi
  exit $status
fi


