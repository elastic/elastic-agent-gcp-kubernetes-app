# Registry

There is a required folder structure for the registry in GCP.

From the [GCP docs](https://cloud.google.com/marketplace/docs/partners/kubernetes/create-app-package#application-images):

> Your Container Registry repository must have the following structure:
> - Your app's main image must be in the root of the repository. For example, if your Container Registry repository is gcr.io/exampleproject/exampleapp, the app's image should be in gcr.io/exampleproject/exampleapp.
> - The image for your deployment container must be in a folder called deployer. In the example above, the deployment image must be in gcr.io/exampleproject/exampleapp/deployer.
> - If your app uses additional container images, each additional image must be in its own folder under the main image. For example, if your app requires a proxy image, add the image to gcr.io/exampleproject/exampleapp/proxy.
> - All of your app's images must be tagged with the release track and the current version. For example, if you're releasing version 2.0.5 on the 2.0 release track, all the images must be tagged with 2.0 and 2.0.5. Learn about organizing your releases.
