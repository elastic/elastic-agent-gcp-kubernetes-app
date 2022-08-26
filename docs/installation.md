# Installation

To install this application you should search for "Elastic Agent" in the GCP Marketplace and install it through the GCP Console.

From the product listing you can choose the version of the application to install.
We maintain `7.17.x` and `8.x` stack versions.
Elastic recommends installing the latest version of the Elastic Agent that’s compatible with the version of your Elasticsearch deployment.
You can review compatibility guidelines [here][1].

By clicking "Configure" a guided process starts to collect some deployment details.

You will need to choose:
- the GKE cluster where to deploy the application: you can select an existing cluster or create a new one;
- the namespace within the GKE cluster to deploy the Application; selecting `default` will deploy the Application to the `default` namespace and the Elastic Agent in the `kube-system` namespace;
- the application instance name (this is the name of the deployed application in your GKE cluster);
- the Service Account of the application; use `default`, **do not change this field**; a dedicated Service Account with required permissions will be created; this field is included because mandatory part of the schema (see [docs][3]);
- Fleet Server URL to connect to; if left empty Kibana Host, Kibana Fleet Username and Kibana Fleet Password are needed;
- Fleet enrollment token; is an Elasticsearch API key to enroll one or more Elastic Agents in Fleet. See: https://www.elastic.co/guide/en/fleet/current/fleet-enrollment-tokens.html. If left empty Kibana Host, Kibana Fleet Username and Kibana Fleet Password are needed;
- Kibana Username; user name to connect to Kibana; this user needs the privileges required to publish events to Elasticsearch;
- Kibana Fleet Password; password to connect to Kibana;
- Kibana Host; URL to connect to Kibana; if you're using Elastic Cloud Kibana URL can be found in the console on the deployment details page;
- Container resource request - CPU; the requested container CPU, depends on use case; more information are available in our [Elastic Agent installation - minimum requirements documentation][2];
- Container Resource Request - Memory; the requested container memory, depends on use case; more information are available in our [Elastic Agent installation - minimum requirements documentation][2].

Once the application is installed it should automatically enroll in Fleet. 

At this point the Elastic Agent is ready to accept policies, but is not yet actively collecting any data, as there is no default policy.

To collect data go to the Fleet UI and configure an Agent Policy.

## Verify the setup

Here are the steps to verify the installation worked as expected:
1. ensure there are no errors in the installed Application page in the GCP Console;
2. verify the Elastic Agent DaemonSet status, by clicking on it under Application Details; check Logs to ensure there are no errors;
3. verify the Elastic Agent correctly enrolled with your Fleet instance; go to the Agents tab in Fleet and ensure the Agent is present and healthy.

**NOTE** that unless you already configured a policy the Agent will not be collecting data.

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