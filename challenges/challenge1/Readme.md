# Challenge 1: Deploying an Azure App Service using Terraform CLI and the Azure CLI

![Astronaut Badger](../assets/Space-Badger-no-circle-smaller.jpg)

**Watch** our [introduction video](https://aka.ms/tfonazure/vid/day1) to learn all about #TerraformOnAzure coding challenge!


## Description

In this first challenge, you will have to deploy our [sample ASP.NET Core application](https://github.com/Terraform-On-Azure-Workshop/AzureEats-Website) to [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/overview?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ). You will have to provision all required Azure resources using [HashiCorp's Terraform](https://www.terraform.io/).

We will be running the web application in **frontend-only mode**. This means that you will be hosting the ASP.NET Core application without a database. As a result, only the home page will be operational. In the following coding challenges you will fix this. Check the paragraph on [running the application in frontend-only mode](#Running-the-application-in-frontend-mode) below on how to achieve this.

There are multiple ways to deploy a web application to Azure App Service. In this coding challenge you will use the Azure CLI to configure the **Azure App Service Deployment Center** [continuous deployment](https://docs.microsoft.com/en-us/azure/app-service/deploy-continuous-deployment?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ). This will configure the App Service to pull the sample application code from a GitHub repo.

Make sure to first [fork the sample application](https://github.com/Terraform-On-Azure-Workshop/TailwindTraders-Website) to your GitHub account, after which you can then configure continuous deployment from GitHub on your App Service.

> **TIP:** the GitHub deployment setting for an App Service cannot be configured through Terraform. You will need to use another automated way to configure this.

## Success criteria 🏆

To successfully complete this challenge, you will 
* Use the Terraform CLI to provision the Azure resources to host 1) an Azure SQL database, 2) a MongoDB database on Azure Container Instances.
* Use the Azure CLI to deploy the sample application from a GitHub repo, using Azure App Service Deployment Center Continuous Deployment (not using GitHub Actions at this time!).


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

## How to get started with Terraform on Azure

There are different ways to get started with Terraform. The easiest is to use the [Azure Cloud shell](https://docs.microsoft.com/en-us/azure/developer/terraform/getting-started-cloud-shell?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ). Alternatively, you can [install Terraform](https://learn.hashicorp.com/terraform/getting-started/install#install-terraform) on your local machine.


## Running the application in frontend mode

To run the application in frontend mode, you need to [configure a number of application settings](https://docs.microsoft.com/en-us/azure/app-service/configure-common?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ). These need to specified on the Azure App Service.

| Setting | Value |
| :------ | :---- |
| WEBSITE_NODE_DEFAULT_VERSION | 10.15.2 |
| ApiUrl                       |  |
| ApiUrlShoppingCart           |  |
| MongoConnectionString        |  |
| SqlConnectionString          |  |
| productImagesUrl             | https://raw.githubusercontent.com/microsoft/TailwindTraders-Backend/master/Deploy/tailwindtraders-images/product-detail |
| Personalizer__ApiKey         |  |
| Personalizer__Endpoint       |  |


## Resources/Tools Used 🚀

A simple App Service and Terraform script should do it for this challenge. Here's a [tutorial](https://docs.microsoft.com/en-us/azure/developer/terraform/provision-infrastructure-using-azure-deployment-slots?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ) on how to get started.

* [Azure Cloud Shell](https://shell.azure.com?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* [Visual Studio Code](https://code.visualstudio.com?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* [Terraform](https://www.terraform.io/)

## More Resources

* ✅ [Using Terraform with Azure documentation](https://docs.microsoft.com/en-us/azure/developer/terraform/overview?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* ✅ [AzureRM provider App Service documentation](https://www.terraform.io/docs/providers/azurerm/r/app_service.html?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* ✅ [Azure App Service documentation](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-get-started-dotnet?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* ✅ [Continuous deployment on Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/deploy-continuous-deployment?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)
* ✅ [Web App deployment using the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/webapp/deployment/source?view=azure-cli-latest?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)


## Questions? Comments? 🙋‍♀️

If you have any questions about the challenges, feel free to open an **[ISSUE HERE](https://github.com/Terraform-On-Azure-Workshop/terraform-azure-hashiconf2020/issues)**.

Make sure to mention which challenge is problematic. We'll get back to you soon!

## I don't have an Azure subscription! 🆘

If you don't have an Azure subscription yet, you can DM us [on Twitter](https://twitter.com/msdev_nl) and we'll provide you with a 30-day Azure subscription! Alternatively, you can also [sign up](https://azure.microsoft.com/en-us/free/) for an Azure free account.
