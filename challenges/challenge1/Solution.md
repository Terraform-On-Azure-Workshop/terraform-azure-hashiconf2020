## Coding Challenge 1: Proposed solution

![Astronaut Badger](../assets/Space-Badger-no-circle-smaller.jpg)

The goal of the [first coding challenge](./Readme.md) was to deploy the sample web application on Azure App Service by
1. provisioning the Azure hosting infrastructure using the Terraform CLI
2. deploy the application from a GitHub repo using App Service Deployment Center continuous deployment. At this time, we're **not** yet setting up a GitHub Actions CI/CD pipeline to deploy the application onto App Service.


## Step 1: Provision the hosting infrastructure on Azure

In the Terraform folder, you can find our [Terraform main.tf](./terraform/main.tf) that provisions all resources on Azure. To deploy on Azure App Service, you will need to provision several individual Azure resources:

* Resource Group
* App Service Plan
* App Service

To allow our script to flexibly deploy in another subscription, use different resource names, or leverage a different deployment location, we're storing these as variables in a [Terraform variables.tf file](./terraform/variables.tf).

When provisioning the App Service, make sure you also configure the App Settings accordingly, as part of the App Service resource!

``` HCL
resource "azurerm_app_service" "main" {
    name                = "${var.prefix}-appservice"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    app_service_plan_id = azurerm_app_service_plan.main.id

    site_config {
        always_on           = true
        default_documents   = [
            "Default.htm",
            "Default.html",
            "hostingstart.html"
        ]
    }

    app_settings = {
        "WEBSITE_NODE_DEFAULT_VERSION"  = "10.15.2"
        "ApiUrl"                        = ""
        "ApiUrlShoppingCart"            = ""
        "MongoConnectionString"         = ""
        "SqlConnectionString"           = ""
        "productImagesUrl"              = "https://raw.githubusercontent.com/microsoft/TailwindTraders-Backend/master/Deploy/tailwindtraders-images/product-detail"
        "Personalizer__ApiKey"          = ""
        "Personalizer__Endpoint"        = ""
    }
}
```

## Step 2: Configure GitHub continuous deployment

To configure the GitHub continuous deployment, we've used the Azure CLI, as described in the [config-github.ps1 script](./scripts/config-github.ps1).

```Powerhell
param([Parameter(Mandatory)][string] $GitHubRepo = "https://github.com/microsoft/TailwindTraders-Website", 
        [string] $branch = "main", 
        [Parameter(Mandatory)][string] $AppServiceName, 
        [Parameter(Mandatory)][string] $ResourceGroupName)
az webapp deployment source config --branch $branch --manual-integration --name $AppServiceName --repo-url $GitHubRepo --resource-group $ResourceGroupName
```

The script takes 4 input parameters:

* GitHub repository name - this is the location of the sample application
* GitHub Branch name
* Target App Service name
* Target Resource Group name

These parameters are then used as an input for the **az webapp deployment** Azure CLI command, which will configure the continuous deployment settings of the App Service.
