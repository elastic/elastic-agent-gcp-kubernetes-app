# Upgrading your installed application

Upgrading the application is **not supported**.

Fleet UI does not allow to upgrade an Elastic Agent running under Kubernetes, as that would conflict with the orchestration performed by Kubernetes itself.

GCP Marketplace does not support upgrading an application via its UI.

## Workaround

To workaround this there are 2 ways:
1. once installed the Application behaves like any other Kubernetes resource. You can edit the application manifest (as you usually would with other Kubernetes resources). To do this, please refer to the Elastic Agent on Kubernetes upgrade documentation;
2. delete the application and install it again with a new version; this approach can be performed directly from the GCP Console, but please **note** that this means performing the installation process from scratch (the installed Agent will not have any policy assigned by default).