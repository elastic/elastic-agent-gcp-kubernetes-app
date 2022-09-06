#!/usr/bin/env bash

set -eou pipefail
[ -n "${DEBUG:-}" ] && set -x

# shellcheck source=./_lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

gcloud_GetImageDigest() {
    local image
    image=$1
    local version
    version=$2
    
    gcloud container images list-tags "$image" --filter="tags ~ $version" --format=json | \
        jq ".[] | select(.tags[] | select(. == \"$version\")) | .digest" --raw-output
}

docker_GetImageDigest() {
    local image
    image=$1
    local version
    version=$2

    docker images --digests --format "{{json .}}"| \
        jq "select(.Repository == \"$image\") | select(.Tag == \"$version\") | .Digest" --raw-output
}

remoteImageDigest() {
    local image
    image=$1
    local version
    version=$2
    local releaseTrack
    releaseTrack=$3

    gcloud_GetImageDigest "$image" "$version"
}

remoteTrackImageDigest() {
    local image
    image=$1
    local version
    version=$2
    local releaseTrack
    releaseTrack=$3

    gcloud_GetImageDigest "$image" "$releaseTrack"
}

localImageDigest() {
    local image
    image=$1
    local version
    version=$2
    local releaseTrack
    releaseTrack=$3

    docker_GetImageDigest "$image" "$version"
}

localTrackImageDigest() {
    local image
    image=$1
    local version
    version=$2
    local releaseTrack
    releaseTrack=$3

    docker_GetImageDigest "$image" "$releaseTrack"
}

# From list of folders to JSON objects: {track: "", version: ""}
folders2Tracks() {
    local versions
    versions=("$@")

    jq --compact-output --null-input '$ARGS.positional' --args -- "${valid[@]}" | \
        jq '[sort | foreach .[] as $e ([]; {"track": ($e | split(".") | .[0:2] | join(".")), "version": $e}; .)]'
}

getLatestTrack() {
    local folders
    folders=("$@")

    # latest track image is simply the latest from folders2Tracks
    # This relies on filesystem sorting
    folders2Tracks  "${folders[@]}" | jq 'last'
}

# this function tags any $image:$version with $releaseTrack and push it to remote GCR.
# Before doing so checks that local image exists and if local and remote digests for 
# $releaseTrack differ.
#
# @param image the docker image to tag and push
# @param version the full version of the image
# @param releaseTrack the release track (major.minor) version desired
componentTagImages() {
    local image
    image=$1
    local version
    version=$2
    local releaseTrack
    releaseTrack=$3
    
    >&2 echo "==> image: $image"

    localDigest=$(localImageDigest "$image" "$version" "$releaseTrack")
    if [ -n "$localDigest" ]; then
        >&2 echo "    local $version digest : $localDigest"
    else
        >&2 echo "    $(tput setaf 1)no $version image in local registry$(tput sgr0)"
        return
    fi

    remoteDigest=$(remoteImageDigest "$image" "$version" "$releaseTrack")
    if [ -n "$remoteDigest" ]; then
        >&2 echo "    remote $version digest: $remoteDigest"
    else
        >&2 echo "    $(tput setaf 1)no $version image in remote registry$(tput sgr0)"
    fi

    localTrackDigest=$(localTrackImageDigest "$image" "$version" "$releaseTrack")
    if [ -n "$localTrackDigest" ]; then
        >&2 echo "    local $releaseTrack digest   : $localTrackDigest"
    else
        >&2 echo "    $(tput setaf 1)no $releaseTrack image in local registry$(tput sgr0)"
    fi

    remoteTrackDigest=$(remoteTrackImageDigest "$image" "$version" "$releaseTrack")
    if [ -n "$remoteTrackDigest" ]; then
        >&2 echo "    remote $releaseTrack digest  : $remoteTrackDigest"
    else
        >&2 echo "    $(tput setaf 1)no $releaseTrack image in local registry$(tput sgr0)"
    fi

    if [ "$localDigest" != "$remoteTrackDigest" ]; then
        >&2 echo -n "    Tagging local $version image as $releaseTrack:"
        docker tag "$image:$version" "$image:$releaseTrack"
        >&2 echo " ✔"
        >&2 echo "    Pushing local $releaseTrack image to remote:"
        docker push "$image:$releaseTrack"
        >&2 echo "    $(tput setaf 2)local digest for $version pushed to remote digest for $releaseTrack$(tput sgr0)"
    else
        >&2 echo "    $(tput setaf 2)local digest for $version equal to remote digest for $releaseTrack$(tput sgr0)"
    fi
}


# Allow overriding GCR location
GCP_GCR="${GCP_GCR:-gcr.io}"

checkvar "GCP_PROJECT_ID" "the GCP project where to move Elastic Agent Docker images"

gcr_elastic_agent_image="$GCP_GCR/$GCP_PROJECT_ID/elastic-agent"
gcr_deployer_image="$GCP_GCR/$GCP_PROJECT_ID/elastic-agent/deployer"

checkvar "ELASTIC_AGENT_VERSION" "the version of the Elastic Agent Docker image to move to GCP_PROJECT_ID"

RELEASE_TRACK=$(echo "$ELASTIC_AGENT_VERSION" | awk -F \. '{version=$1"."$2; print version}')

# get all folders in CWD
versions=(*/)

valid=()

# collect valid image tag names (from folder names)
for f in "${versions[@]}"; do
    v=$(echo "$f" | awk '{ print substr( $0, 1, length($0)-1 ) }')
    # get all folders starting with $RELEASE_TRACK
    if [[ "$v" == $RELEASE_TRACK* ]]; then valid+=("$v"); fi
done

>&2 echo "==> Versions found for $(tput bold)$RELEASE_TRACK$(tput sgr0): $(tput bold)${valid[*]}$(tput sgr0)"

[ -n "${DEBUG:-}" ] && folders2Tracks "${valid[@]}"
[ -n "${DEBUG:-}" ] && getLatestTrack "$(folders2Tracks "${valid[@]}")"

version=$(getLatestTrack "${valid[@]}" | jq -r ".version")
releaseTrack=$(getLatestTrack "${valid[@]}" | jq -r ".track")

>&2 echo
>&2 echo "==> $(tput bold)release track $releaseTrack, candidate image: $version$(tput sgr0)"

componentTagImages "$gcr_elastic_agent_image" "$version" "$releaseTrack"
componentTagImages "$gcr_deployer_image" "$version" "$releaseTrack"