# Proposed Solution: Challenge 3: Remote state and CI/CD with GitHub Actions

The aim of [challenge 3](./Readme.md) was to setup our deployment for team development, by setting up a CI/CD workflow on GitHub Actions. To do so, there were a few additional steps that need to be taken, namely configuring Terraform remote state on Azure Storage, as well as authentication with Azure through Service Principals.

## Step 1: Configuring Terraform Remote State

We pretty much gave that one away, didn't we? To configure the remote state on Azure Storage, we have a **[detailed tutorial](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ)** available for you on our Azure Docs site!

You first **create a Azure Storage account** to hold your remote state - btw, did you also a Terraform script to do this? 

Once created, you then **configure your main Terraform** file to use this remote state.

```Terraform
terraform {
    backend "azurerm" {
        resource_group_name   = var.remote_state_rg
        storage_account_name  = var.remote_state_storage
        container_name        = var.remote_state_container_name
        key                   = var.remote_state_key
    }
}
```

After running a ```terraform init``` and `terraform apply`, you should be all set to have remote state configured.


## Step 2: Authenticating using a Service Principal

As we don't have interactive login when running inside a CI/CD pipeline, we need to authenticate to Azure using a Service Principal. Again, we had a **[tutorial](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)** lined up for you!

We will then be using the details of the service principal in our GitHub Actions workflow.


## Step 3: Creating a GitHub Actions workflow

Our GitHub Actions workflow consists of two jobs:

1. Terraform: provision all infrastructure components using the Terraform CLI
2. Deploy:  use the Azure CLI to configure the App Service continuous deployment to pull the sources from our GitHub repo.

Check our full [GitHub Actions workflow](./github/tf-actions-main.yaml) for all details.

When running ```terraform init``` and ```terraform apply```, we need to connect to Azure, either for connecting to remote state (init) or for deploying our resources (apply).

Make sure to configure those connection parameters in the **secrets configuration** of your GitHub repo, not to expose any secrets in your code!
![](https://www.terraform.io/docs/github-actions/images/setup-terraform/secrets-7f1edc05.png)
