# Installation

To install this application you should search for "Elastic Agent" in the GCP Marketplace and install it through the GCP Console.

From the product listing you can choose the version of the application to install.
We maintain `7.17.x` and `8.x` stack versions.
Elastic recommends installing the latest version of the Elastic Agent that’s compatible with the version of your Elasticsearch deployment.
You can review compatibility guidelines [here][1].

The installation process requires:
- an Elastic Stack deployment (either on prem or on [Elastic Cloud](https://www.elastic.co/cloud/));
- a [running Fleet server](https://www.elastic.co/guide/en/fleet/current/fleet-server.html);
- a running GCP GKE cluster.

## Preparing Elastic Cluster for Kubernetes monitoring

**NOTE**: to collect information required by dashboards created by the [Kubernetes Integration][5], you need to deploy [`kube-state-metrics`][6]. Follow their documentation and deploy it. If Elastic Agent will not be deployed in the same namespace you will need to change the integration policy defaults (see [this issue][7] for further details).

Before installing the application we need to create a Fleet enrollment token, required in the installations step. To create a Fleet enrollment token you need to have an Agent policy. Then [follow the documentation][4].

## Installing the application from GCP marketplace

By clicking "Configure" (_link to listing TBD_) a guided process starts to collect some deployment details.

You will need to choose:
- the GKE cluster where to deploy the application: you can select an existing cluster or create a new one;
- the namespace within the GKE cluster to deploy the Application;
- the application instance name (this is the name of the deployed application in your GKE cluster);
- the Service Account of the application; a dedicated Service Account with required permissions should be created; this field is included because mandatory part of the schema (see [docs][3]);
- Fleet Server URL to connect to;
- Fleet enrollment token; is an Elasticsearch API key to enroll one or more Elastic Agents in Fleet. See: https://www.elastic.co/guide/en/fleet/current/fleet-enrollment-tokens.html;
- Container resource request - CPU; the requested container CPU, depends on use case; more information are available in our [Elastic Agent installation - minimum requirements documentation][2];
- Container Resource Request - Memory; the requested container memory, depends on use case; more information are available in our [Elastic Agent installation - minimum requirements documentation][2].

Once the application is installed it should automatically enroll in Fleet. 

At this point the Elastic Agent is ready to accept policies, but is not yet actively collecting any data, as there is no default policy.

To collect data go to the Fleet UI and configure an Agent Policy.

## Verify the setup

Here are the steps to verify the installation worked as expected:
1. ensure there are no errors in the installed Application page in the GCP Console;
2. verify the Elastic Agent DaemonSet status, by clicking on it under Application Details; check Logs to ensure there are no errors;
3. verify all Pods from Elastic Agent DaemonSet have been correctly deployed;
4. verify the Elastic Agent correctly enrolled with your Fleet instance; go to the Agents tab in Fleet and ensure the Agent is present and healthy.

**NOTE** that unless the policy linked to the Fleet enrollment token has some integration configure, the Agent will not be collecting data yet.

## Debugging

The GCP Console allows to perform graphically what you could do with command line tools. If something is not working as expected the best way to troubleshoot (apart from reading console messages around deployment) is to use `kubectl` tool and perform usual Kubernetes debugging steps:
- check cluster events
- check Elastic Agent DaemonSet and Pods status

If you need specific assistance you can:
- ask for suggestion and guidance on [Elastic Discuss](https://discuss.elastic.co/);
- (if you have a [subscription](https://www.elastic.co/subscriptions)) get in touch with [Elastic Support](https://support.elastic.co/).


[1]: https://www.elastic.co/support/matrix#matrix_compatibility
[2]: https://www.elastic.co/guide/en/fleet/current/elastic-agent-installation.html#_minimum_requirements
[3]: https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/schema.md?rgh-link-date=2022-08-23T11%3A04%3A33Z#type-service_account
[4]: https://www.elastic.co/guide/en/fleet/master/fleet-enrollment-tokens.html#create-fleet-enrollment-tokens
[5]: https://docs.elastic.co/en/integrations/kubernetes
[6]: https://github.com/kubernetes/kube-state-metrics
[7]: https://github.com/elastic/integrations/issues/4667
