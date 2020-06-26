# Challenge 4: Deploying to Azure Kubernetes Service

![Rocket Lift-off](../assets/Liftoff-Badger-400x400.png)

**Watch** our [introduction video](https://aka.ms/tfonazure/vid/day4) to learn all about this #TerraformOnAzure coding challenge!

## Description

Now that we have our CI/CD pipeline setup for the team, it's time to pimp our web hosting to run on a Kubernetes cluster, specifically [Azure Kubernetes Services](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ) (AKS). AKS is a fully managed Kubernetes cluster in Azure, and reduces the complexity of managing Kubernetes by offloading much of the operational responsibility to Azure.

The first step to deploy an application to a Kubernetes cluster, is to create container image using the Docker CLI. How this container image is created is described in a **Dockerfile**.  The sample application already contains a preconfigured Dockerfile.

The next step is to publish this container image to a container repository, this could be **[Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)** (ACR) or any other registry (e.g. Docker Hub).

You can find a [tutorial on how to publish a container image in ACR](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ) in our documentation site.

Finally, we need to describe how to deploy our application on a Kubernetes cluster. To do this, you can use the open-source [Helm packaging tool](https://helm.sh). You will find a Helm chart in the [sample application](https://github.com/Terraform-On-Azure-Workshop/AzureEats-Website) repo.

> **Note:** make sure to update the image repository in the ```values.yaml``` file of the Helm chart to match your container repository:

```yaml
image:
  repository: tailwindtradersacr.azurecr.io/web.api
  tag: prod
  pullPolicy: Always
```


## Success criteria 🏆

To successfully complete this challenge, you will need to:

1. Use the Docker CLI to build a Docker image for the sample application and store it in a container registry
2. Use the Terraform CLI to provision an AKS cluster.
3. Deploy the [sample application](https://github.com/Terraform-On-Azure-Workshop/AzureEats-Website) on the AKS cluster using Helm

Spoiler: the [solution](./Solution.md) to this coding challenge is now available.


## How to submit your solution?

Within 24 hours of making the coding challenge public, submit your solution as a custom ISSUE to this GitHub repository.

 1. Create your own Github repo with your solution for that challenge.
 2. Create a new [Challenge Solution Submission issue](https://github.com/Terraform-On-Azure-Workshop/terraform-azure-hashiconf2020/issues/new/choose) in our repo for each challenge and fill all the details.
 3. Submit the issue.

## Prerequisites

- An Azure subscription, where you have permissions to create resource groups. You can get an [Azure free account](https://azure.microsoft.com/en-us/free/?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ) or send us a DM us [on Twitter](https://twitter.com/msdev_nl) and we'll provide you with an Azure Pass.
- A [GitHub account](https://github.com/), allowing you to create a custom issue to submit your solution. 
- Fork the [sample application](https://github.com/Terraform-On-Azure-Workshop/AzureEats-Website) to your GitHub account.

## Resources/Tools Used 🚀

* [Azure Cloud Shell](https://shell.azure.com)
* [Visual Studio Code](https://code.visualstudio.com)
* [Terraform](https://www.terraform.io/)

## More Resources

* ✅ [Azure Kubernets Service documentation](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* ✅ [Tutorial: Create a Kubernetes cluster with AKS and Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* ✅ [Tutorial: deploy an existing application to AKS using Helm](https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)


## Questions? Comments? 🙋‍♀️

If you have any questions about the challenges, feel free to open an **[ISSUE HERE](https://github.com/Terraform-On-Azure-Workshop/terraform-azure-hashiconf2020/issues)**.

Make sure to mention which challenge is problematic. We'll get back to you soon!

## I don't have an Azure subscription! 🆘

If you don't have an Azure subscription yet, you can DM us [on Twitter](https://twitter.com/msdev_nl) and we'll provide you with a 30-day Azure subscription! Alternatively, you can also [sign up](https://azure.microsoft.com/en-us/free/) for an Azure free account.
