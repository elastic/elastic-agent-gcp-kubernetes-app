#!/usr/bin/env bash

set -eou pipefail
[ -n "${DEBUG:-}" ] && set -x

unset ELASTIC_AGENT_VERSION
. "$(dirname "${BASH_SOURCE[0]}")/check.sh"