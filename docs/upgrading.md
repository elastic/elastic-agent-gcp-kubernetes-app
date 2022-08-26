# Upgrading your installed application

Is possible to upgrade the application either by modifing the Kubernetes Resource definition or by deleting and re-installing the application from GCP Console.

Note that upgrading through Fleet or through the GCP Marketplace is not supported:
- Fleet UI does not allow to upgrade an Elastic Agent running under Kubernetes, as that would conflict with the orchestration performed by Kubernetes itself;
- GCP Marketplace does not support upgrading an application in place.

## By Kubernetes resources

Once installed the Application behaves like any other Kubernetes resource.
You can edit the application manifest as you usually would with other Kubernetes resources.
To do this, please refer to the [Elastic Agent on Kubernetes upgrade documentation][1].

## From the GCP Console

Delete the application and install it again with a new version.
This approach can be performed directly from the GCP Console, but please **note** that this means performing the installation process from scratch.



[1]: https://www.elastic.co/guide/en/fleet/master/upgrade-elastic-agent.html