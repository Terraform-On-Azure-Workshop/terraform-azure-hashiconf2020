# Proposed Solution: Challenge 2: Deploying databases on Azure using Terrform CLI

In challenge 1 we provisioned the base infrastructure to host the web application on Azure App Service and get it deployed using App Service Continuous Deployment.

The goal of the [second challenge](./Readme.md) was then to provision both application databases on Azure and connect them to the application running on App Service, all using the Terraform CLI. The products database needs to be hosted on Azure SQL Database, and the shopping cart database is a MongoDB database, hosted on Azure Container Instances.

## Step 1: Provision the products database on Azure SQL Database

[**Azure SQL Database**](https://docs.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ) is a managed database service, so you don't have to take care of managing the server infrastructure, high-availability or geo-replication.

To provision this database on Azure, we need to create two Azure resources:

* **Azure SQL Database Server**
* **Azure SQL Database**


There is a corresponding resource in the AzureRM Terraform provider:

* [azurerm_sql_server](https://www.terraform.io/docs/providers/azurerm/r/sql_server.html)
* [azurerm_sql_database](https://www.terraform.io/docs/providers/azurerm/r/sql_database.html)

This is how we achieved it (check the [full Terraform script](./terraform/main.tf)). You notice that we need to provide an admin username and password for the SQL Server. We're providing these values through input parameters for our script.

```Terraform
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
```

By default, our SQL Database is not accepting any connections. To allow our application, running on Azure App Service, to connect to the database, we need to **configure a firewall rule** on the Azure SQL Server to allow other Azure services to connect to this it.

Again, we have a Terraform resource for this: [azurerm_sql_firewall_rule](https://www.terraform.io/docs/providers/azurerm/r/sql_firewall_rule.html). By setting the start and end IP address to *0.0.0.0*, Azure knows that it should allow Azure services access to the SQL Server.

```Terraform
# Allow Azure services to acccess the Azure SQL DB
resource "azurerm_sql_firewall_rule" "sqlfirewall" {
    name                = "${var.prefix}-sqlfirewall"
    resource_group_name = azurerm_resource_group.main.name
    server_name         = azurerm_sql_server.sqlserver.name
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "0.0.0.0"
}
```

## Step 2: Provision the shopping cart MongoDB on Azure Container Instances

[**Azure Container Instances**](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-overview?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ) allows you to easily host a Docker container, without having to take care of the infrastructure to host this container. You simply provide a container image, specify how many memory and CPU resources you need, and the platform will spin up your container.

As we will be running a MongoDB database in the container, we're using the standard [mongo](https://hub.docker.com/_/mongo/) container image from DockerHub.

Using the Terraform [azurerm_container_group](https://www.terraform.io/docs/providers/azurerm/r/container_group.html) resource, we can provision an ACI. The image name can be specified through the *container.image* parameter.


```Terraform
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
```

You will notice that we provide the **MongoDB admin username and password** by setting the corresponding environment variables (*MONGO_INITDB_ROOT_USERNAME* and *MONGO_INITDB_ROOT_PASSWORD*).

We also need to explicitly **configure the port numbers** that need to be opened. MongoDB uses port number 27017 by default for applications to connect to it.

> For the sake of simplicity, we have not configured external storage for our container to store the MongoDB database files. This means that if the container is stopped, the entire container is reset and all data is wiped. In a production setup, you would attach external storage to your container, e.g. using Azure Storage, to ensure that data survives container restarts.


## Step 3: Connect the application to the databases

To connect the application to our databases, we need to update the application's app settings on Azure App Service. We have 2 corresponding settings: **MongoConnectionString** and **SqlConnectionString**. 

We can reference the newly created database resources by refering to the Terraform resource and resource name. For example, to refer to the Azure SQL Database fully qualified domain name:

```Terraform
${azurerm_sql_server.sqlserver.fully_qualified_domain_name}
```

Here's the full updated set op app settings for our application:

```Terraform
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
```
