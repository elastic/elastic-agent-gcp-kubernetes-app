Documentation is available for GCP K8s app schema: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/schema.md

We are using [V2 Specification]

[V2 Specification]: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/00fa7b864165fe19786d4618b07e9ce0478d922e/docs/schema.md

## Notable fields

`publishedVersion`: require and **must match** the release tag of the `deployer` image.

`publishedVersionMetadata.releaseNote`: text field for release notes. 

`publishedVersionMetadata.releaseTypes`: one of `Feature`, `BugFix`, `Security`. `Security` should only be used if this is an important update to patch an existing vulnerability.

`recommended`: when `true` indicates that users are encouraged to update as soon as possible.