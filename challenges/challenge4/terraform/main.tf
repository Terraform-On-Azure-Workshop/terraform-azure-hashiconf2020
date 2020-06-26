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

# Create a log analytics workspace
resource "azurerm_log_analytics_workspace" "logws" {
    name                = "${var.prefix}-logws"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    sku                 = "PerGB2018"
}

# Create a log analytics solution to capture the logs from the containers on our cluster
resource "azurerm_log_analytics_solution" "logsol" {
    solution_name           = "ContainerInsights"
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name
    workspace_resource_id   = azurerm_log_analytics_workspace.logws.id
    workspace_name          = azurerm_log_analytics_workspace.logws.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

# Create an AKS cluster
resource "azurerm_kubernetes_cluster" "k8s" {
    name                    = "${var.prefix}-aks"
    location                = azurerm_resource_group.main.location
    resource_group_name     = azurerm_resource_group.main.name
    dns_prefix              = "${var.prefix}-aks"

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = 3
        vm_size         = "Standard_DS1_v2"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

    addon_profile {
        oms_agent {
            enabled                    = true
            log_analytics_workspace_id = azurerm_log_analytics_workspace.logws.id
        }
    }
}

# Create an Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
    name                        = "${var.prefix}-acr"
    location                    = azurerm_resource_group.main.location
    resource_group_name         = azurerm_resource_group.main.name
    sku                         = "Premium"
    admin_enabled               = false
}
