# Deploy sample app on Azure App Services in a standalone manner.
# The application has two databases:
#   - Azure SQL DB: products database
#   - MongoDB on ACI: shopping cart database

# Configure the AzureRM provider
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
        "ApiUrl"                        = "/api/v1"
        "ApiUrlShoppingCart"            = "/api/v1"
        "MongoConnectionString"         = "mongodb://${var.mongodb_master_username}:${var.mongodb_master_password}@${azurerm_container_group.aci.ip_address}:27017/?authSource=admin&authMechanism=SCRAM-SHA-1"
        "SqlConnectionString"           = "Server=tcp:${azurerm_sql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sqldb.name};Persist Security Info=False;User ID=${var.sql_master_username};Password=${var.sql_master_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        "productImagesUrl"              = "https://raw.githubusercontent.com/suuus/TailwindTraders-Backend/master/Deploy/tailwindtraders-images/product-detail"
        "Personalizer__ApiKey"          = ""
        "Personalizer__Endpoint"        = ""
    }
}

# Provision Azure SQL DB server instance
resource "azurerm_sql_server" "sqlserver" {
    name                         = "${var.prefix}-sqlserver"
    location                     = azurerm_resource_group.main.location
    resource_group_name          = azurerm_resource_group.main.name
    version                      = "12.0"
    administrator_login          = var.sql_master_username
    administrator_login_password = var.sql_master_password
}

# Provision the Azure SQL Database (products database)
resource "azurerm_sql_database" "sqldb" {
    name                = "${var.prefix}-sqldb"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    server_name         = azurerm_sql_server.sqlserver.name
}

# Allow Azure services to acccess the Azure SQL DB
resource "azurerm_sql_firewall_rule" "sqlfirewall" {
    name                = "${var.prefix}-sqlfirewall"
    resource_group_name = azurerm_resource_group.main.name
    server_name         = azurerm_sql_server.sqlserver.name
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "0.0.0.0"
}

# Create an Azure Container Instance to host the MongoDB container (shopping cart)
resource "azurerm_container_group" "aci" {
    name                = "${var.prefix}-aci"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    ip_address_type     = "public"
    dns_name_label      = "${var.prefix}-mongodb"
    os_type             = "Linux"

    container {
        name   = "mongodb"
        image  = "mongo"
        cpu    = "1"
        memory = "2"

        ports {
            port     = 27017
            protocol = "TCP"
        }

        commands = []

        secure_environment_variables = {
            MONGO_INITDB_ROOT_USERNAME  = var.mongodb_master_username
            MONGO_INITDB_ROOT_PASSWORD  = var.mongodb_master_password
        }
    }
}

