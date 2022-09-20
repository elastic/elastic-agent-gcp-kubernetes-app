# Next steps

If you successfully installed the application by following the steps [here](./installation.md), great job! Now you're ready to collect some data!

By default the Elastic Agent will be assigned the Fleet Integration Policy linked to the Fleet enrollment token you used when installing the application. If that policy has some Integrations configured, the Agent should already be collecting data.

If there is no Integration configured, here is a list of common use cases and how to setup Elastic Agent policies to collect related data.

## Kubernetes Observability

If you need to monitor the GKE cluster you deployed the application in, you need the [`kubernetes` integration][k8s-integration].

Before setting up the policy with the `kubernetes` integration, ensure to have installed `kube-state-metrics`, which is used by the integration to collect advanced state objects information. Guidance on `kube-state-metrics` usage is [in their docs][3].

In case you are monitoring a large cluster there are some [considerations][2] to keep in mind.

Given the constraint of the managed environment the application runs in (GKE) [there are some limitations][1] to the available data collection when using the Kubernetes integration.

[1]: https://www.elastic.co/guide/en/fleet/master/running-on-kubernetes-managed-by-fleet.html#_deploying_elastic_agent_to_managed_kubernetes_environment
[2]: https://www.elastic.co/guide/en/fleet/master/running-on-kubernetes-managed-by-fleet.html#_deploying_elastic_agent_to_collect_cluster_level_metrics_in_large_clusters
[3]: https://github.com/kubernetes/kube-state-metrics#kubernetes-deployment

## GCP Observability

If you need to monitor GCP resources, you need the [`gcp` integration][gcp-integration].

[k8s-integration]: https://docs.elastic.co/en/integrations/kubernetes
[gcp-integration]: https://docs.elastic.co/integrations/gcp