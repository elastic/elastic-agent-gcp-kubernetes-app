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

getTracks() {
    local versions
    versions=("$@")

    # Convert a BASH array to jq array and apply a tranformation to collect all 
    # track versions and their respective latest version based on the folders available.
    # The resulting value is an object in the form of: { track: version, ... } for each 
    # track identified by the list of folders.
    # NOTE: This is made possible by using the version string as folder name.
    # NOTE: the order of the list is meaningful, as the reduce overwrites previous entries;
    #       this allows to get the **latest** version for the given release track.
    jq --compact-output --null-input '$ARGS.positional' --args -- "${versions[@]}" | \
    jq '[sort | foreach .[] as $e ([]; {"track": ($e | split(".") | .[0:2] | join(".")), "version": $e}; .)] | INDEX(.track)'
}

findInLocalRegistry() {
    local image
    image=$1
    local version
    version=$2

    num=$(docker images "$image:$version" -q | wc -l)
    if [[ $num -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

findInRemoteRegistry() {
    local image
    image=$1
    local version
    version=$2

    # This command returns true or false based on existance of the specified tag on the specified image
    # in the remote registry.
    # It collects all tags, filters them with jq and returns true or false based on the length of the result. If
    # the filtered result is 0-length the image:tag combination is missing.
    # NOTE: this is because there is no way to filter for a tag if the same tag is a substring of another tag 
    # (i.e. 8.3 substring of 8.3.0, 8.3.1, 8.3.2, ...).
    exists=$(gcloud container images list-tags "$image" --flatten='tags' --format json | jq "[.[] | select(.tags == \"$version\")] | length != 0")

    if [[ "$exists" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

tagAndPushImage() {
    local image
    image=$1
    local version
    version=$2
    local releaseTrack
    releaseTrack=$3

    # the local image must be present to tag&push it
    if findInLocalRegistry "$image" "$version"; then
        docker tag "$image:$version" "$image:$releaseTrack"
        docker push "$image:$releaseTrack"
    else
        >&2 echo "    no local image, skipping"
    fi
}

tagImages() {
    local images
    images=("$@")

    [ -n "${DEBUG:-}" ] && getTracks "${images[@]}" | jq -c

    for f in $(getTracks "${images[@]}" | jq -c ".[]"); do
        version=$(jq -r ".version" <<< "$f")
        releaseTrack=$(jq -r ".track" <<< "$f")

        >&2 echo
        >&2 echo "==> $(tput bold)release track $releaseTrack, candidate image: $version$(tput sgr0)"

        # agent
        >&2 echo "==> agent remote:"
        if findInRemoteRegistry "$gcr_elastic_agent_image" "$version"; then
            gcloud container images list-tags "$gcr_elastic_agent_image" --filter="tags ~ $version"
        else
            >&2 echo "    no $version image in remote registry"
        fi
        if findInRemoteRegistry "$gcr_elastic_agent_image" "$releaseTrack"; then
            gcloud container images list-tags "$gcr_elastic_agent_image" --filter="tags ~ $releaseTrack"
        else
            >&2 echo "    no image $releaseTrack image in remote registry"
        fi
        >&2 echo "==> agent local:"
        if findInLocalRegistry "$gcr_elastic_agent_image" "$version"; then
            docker images "$gcr_elastic_agent_image:$version"
        else
            >&2 echo "    no $version image in local registry"
        fi
        if findInLocalRegistry "$gcr_elastic_agent_image" "$releaseTrack"; then
            docker images "$gcr_elastic_agent_image:$releaseTrack"
        else
            >&2 echo "    no $releaseTrack image in local registry"
        fi
        
        >&2 echo ""
        tagAndPushImage "$gcr_elastic_agent_image" "$version" "$releaseTrack"

        # deployer    
        >&2 echo "==> deployer remote:"
        if findInRemoteRegistry "$gcr_deployer_image" "$version"; then
            gcloud container images list-tags "$gcr_deployer_image" --filter="tags ~ $version"
        else
            >&2 echo "    no $version image in remote registry"
        fi
        if findInRemoteRegistry "$gcr_deployer_image" "$releaseTrack"; then
            gcloud container images list-tags "$gcr_deployer_image" --filter="tags ~ $releaseTrack"
        else
            >&2 echo "    no image $releaseTrack image in remote registry"
        fi 
        >&2 echo "==> deployer local:"
        if findInLocalRegistry "$gcr_deployer_image" "$version"; then
            docker images "$gcr_deployer_image:$version"
        else
            >&2 echo "    no $version image in local registry"
        fi
        if findInLocalRegistry "$gcr_deployer_image" "$releaseTrack"; then
            docker images "$gcr_deployer_image:$releaseTrack"
        else
            >&2 echo "    no $releaseTrack image in local registry"
        fi
        
        >&2 echo ""
        tagAndPushImage "$gcr_deployer_image" "$version" "$releaseTrack"
    done
}

versions=(*/)

v7=()
v8=()

for f in "${versions[@]}"; do
    v=$(echo "$f" | awk '{ print substr( $0, 1, length($0)-1 ) }')
    if [[ "$v" == 7* ]]; then v7+=("$v"); fi
    if [[ "$v" == 8* ]]; then v8+=("$v"); fi
done

tagImages "${v7[@]}"
tagImages "${v8[@]}"
