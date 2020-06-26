# Proposed Solution: Challenge 4: Deploying to Azure Kubernetes Service

In [challenge 4](./Readme.md) the goal is to deploy the sample application to Azure Kubernetes Service (AKS). As outlined in the challenge description, this is a multi-step process. We'll go over the individual steps here. To fully automate the provisioning and deployment, you can incorporate each of those steps in your CI/CD workflow, that we setup in [challenge 3](../challenge3/Readme.md).


## Step 1: Provisioning an AKS cluster using the Terraform CLI

We have a [tutorial on Azure Docs](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ) that takes you step-by-step through the process of setting up an AKS cluster using Terraform.

From our ```main.tf``` we can remove the App Service Plan and App Service resources. The Terraform CLI will de-provision these automatically as a result, when performing a ```terraform apply```.

The we can add the Terraform code for provisioning the AKS cluster:

```Terraform
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
```

Note that provisioning an AKS cluster can take several minutes to complete.


## Step 2: Get the Kubernetes configuration for the AKS cluster

To allow connecting to the AKS cluster, you will need to retrieve the Kubernetes configuration. This can be done through the Azure CLI:

```shell
az aks get-credentials -n <cluster name> -g <resource group name>
```


## Step 3: Creating an Azure Container Registry (ACR)

To publish the Docker container image for our application, we need a container repository. In our solution we're using the [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-intro?ocid=aid3015373_ThankYou_DevComm&eventId=HashiConfTerraformonAzure_JK1-K2-hoArJ).

We can provision the ACR using the Terraform CLI, namely using the [azurerm_container_registry resource](https://www.terraform.io/docs/providers/azurerm/r/container_registry.html):

```Terraform
resource "azurerm_container_registry" "acr" {
    name                        = "${var.prefix}-acr"
    location                    = azurerm_resource_group.main.location
    resource_group_name         = azurerm_resource_group.main.name
    sku                         = "Premium"
    admin_enabled               = false
}
```

## Step 4: Build the docker image and push it to the registry

Now that we have the infrastructure provisioned, we can **build the container image** for the application. This is done through the **Docker CLI**. There is already a ```Dockerfile``` included in the sample application source code that builds the ASP.NET Core application and exposes it on port 80.

When building the docker image, we need to provide the image name and tag (we're using 'v1' as the tag name). In the following step, we'll push this image to our container registry. For that to work, we need to prefix the image name with the fully qualified domain name (FQDN) of our registry. For example:

```shell
docker build -t ttacrze222xbozcumm.azurecr.io/azureeats:v1 ."
```

Now that we have built the docker image locally, we can **push it to our container registry**. This can be achieved using the Docker CLI:

```shell
docker push ttacrze222xbozcumm.azurecr.io/azureeats:v1
```


## Step 5: Deploy the application on AKS using Helm

We now have the docker image for our sample application up in our container registry. We can now create the [Helm](https://helm.sh) chart to **deploy this image on our AKS cluster**.

The Helm chart for our application has a reference to the contaimer image in the ```values.yaml``` file. Make sure to update the image name according to the name of your container registry.

In our Helm chart, we're defining a Kubernetes LoadBalancer Service that will expose our application on a public IP address on port 80. Underlying, it uses the Azure Load Balancer to achieve this.

To deploy the Helm chart on the Kubernetes, we're using the Helm CLI:

```shell
helm install -n azureeatsrelease .
```
