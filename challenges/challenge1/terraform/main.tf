# Deploy sample app on Azure App Services in a standalone manner, no database required.

# Configure the AzureRM provider (using v2.1)
provider "azurerm" {
    version         = "~>2.14.0"
    subscription_id = var.subscription_id
    features {}
}

# Provision a resource group to hold all Azure resources
resource "azurerm_resource_group" "main" {
    name            = "${var.prefix}-resources"
    location        = var.location
}

# Provision the App Service plan to host the App Service web app
resource "azurerm_app_service_plan" "main" {
    name                = "${var.prefix}-asp"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    kind                = "Windows"

    sku {
        tier = "Standard"
        size = "S1"
    }
}

# Provision the Azure App Service to host the main web site
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
