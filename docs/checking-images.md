# Checking images

The script `./tools/scripts/check.sh` can check if app folders in the root of the repository have corresponding images in the GCR registry.

Example output:
```
❯ direnv exec infra/elastic-obs-integrations-dev/ ./tools/scripts/check.sh
direnv: loading ~/code/github.com/elastic/elastic-agent-gcp-kubernetes-app/infra/elastic-obs-integrations-dev/.envrc
Checking images in GCP project: elastic-obs-integrations-dev
ELASTIC_AGENT_VERSION not set, checking all found versions
8.1.0 agent   : 6c95b9553c81  8.1.0      2022-05-09T17:35:42
8.1.0 deployer: 7f61726b0f3e  8.1.0      2022-05-09T16:23:38
8.1.1 agent   : f25d473e0c9e  8.1.1      2022-05-09T16:29:40
8.1.1 deployer: c7d8c42192d0  8.1.1      2022-05-09T16:23:59
8.1.2 agent   : 067086d78c07  8.1.2      2022-05-09T16:29:43
8.1.2 deployer: 98515add6dba  8.1.2      2022-05-09T16:30:03
8.1.3 agent   : c1c489ea68a8  8.1,8.1.3  2022-05-09T16:29:46
8.1.3 deployer: 44dab3bb2aab  8.1,8.1.3  2022-05-11T17:46:30
```

Images from `8.1.0` to `8.1.3` are listed, both app image and deployer image. For each the container digest, tags and creation date are printed.

Note the `8.1` tag attached to `8.1.3`, to signal the latest version for the release track.