#!/usr/bin/env bash

# Checks that a variable with the given name is set
# If it's not set print a message on stderr and exit 1
# checkvar $varname $description
checkvar() {
    local varname
    varname="$1"
    local desc
    desc="$2"

    if [ -z "${!varname:-}" ]; then
        >&2 echo "$varname must be set" 
        >&2 echo "$varname: $desc"
        exit 1
    fi
}

# Returns 0 if there is a build-id file in the relative elastic-agent folder
# If it's not set print a message on stderr and exit 1
# checkvar $varname $description
has_buildID() {
    if [ -f "./$ELASTIC_AGENT_VERSION/build-id.$GCP_PROJECT_ID" ]; then
        return 0
    fi

    return 1
}

next_buildID() {
    if has_buildID; then
        buildID=$(read_buildID)
        buildID=$(("$buildID" + 1))
    else
        buildID=1
    fi

    echo "$buildID"
}

read_buildID() {
    cat <"./$ELASTIC_AGENT_VERSION/build-id.$GCP_PROJECT_ID"
}

write_buildID() {
    local buildID
    buildID="$1"

    echo "$buildID" > "./$ELASTIC_AGENT_VERSION/build-id.$GCP_PROJECT_ID"
    echo "$buildID"
}

calculate_next_version() {
    version "$ELASTIC_AGENT_VERSION" "$(next_buildID)"
}

get_current_version() {
    if has_buildID; then
        buildID=$(read_buildID)
    else
        buildID=1
    fi

    version "$ELASTIC_AGENT_VERSION" "$buildID"
}

version() {
    local v
    v="$1"
    local b
    b="$2"

    # TODO: leaving this here for the moment but it can probably be removed. Pushing the same tag again on 
    # GCR moves the tag to the new digest, so it works even without the -gke.x suffix.
    # On the human side being able to distinguish versions without looking at the digest may be helpful, 
    # I'm not sure is worth the maintenance effort. If this is not used all buildID related code can be removed.
    # echo "$v-gke.$b" 

    echo "$v" 
}