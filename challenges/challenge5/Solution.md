# Proposed solution: Challenge 5: connecting it all with Consul

In this final challenge, the goal was to set up [Consul](https://www.consul.io) on the AKS cluster using [Terraform](https://www.terraform.io) and create a Service Mesh that [spans](https://www.consul.io/docs/connect/mesh-gateway) all of the AKS clusters of everyone participating.

## Step 1: Setting up Consul on AKS

In the [consul.tf](./terraform/consul.tf) file, you will deploy the Consul helm chart on the AKS cluster. This is achieved using the ```helm_release``` resource of the Helm Terraform provider.

```Terraform
resource "helm_release" "consul" {
  depends_on = [kubernetes_secret.consul-federation]

  repository = "https://helm.releases.hashicorp.com"

  name      = "consul"
  chart     = "consul"
  namespace = "default"
  version   = "0.21.0"

  values = [
    "${file("${path.module}/files/values.yaml")}"
  ]

  set {
    name  = "meshGateway.wanAddress.static"
    value = azurerm_public_ip.gateway.ip_address
  }
}
```

The Consul cluster **must be federated with the primary datacenter**. To [federate](https://www.consul.io/docs/connect/wan-federation-via-mesh-gateways) the Consul clusters, you need to create a Kubernetes secret, containing all the needed configuration to federate Consul, from the `assets/consul-federation-secret.yaml` file.

## Step 2: Expose Mesh Gateways on a public IP address

In order for the Mesh Gateways to reach each other, they need to be **exposed on a public IP**.
This can be done by [creating a static IP](https://www.terraform.io/docs/providers/azurerm/r/public_ip.html) and a [Kubernetes service](https://docs.microsoft.com/en-us/azure/aks/static-ip#create-a-service-using-the-static-ip-address) with [Terraform](https://www.terraform.io/docs/providers/kubernetes/r/service.html) that points at the selectors `app=consul` and `component=mesh-gateway`.

```Terraform
resource "azurerm_public_ip" "gateway" {
  name                = "gateway"
  resource_group_name = data.azurerm_resource_group.participant.name
  location            = data.azurerm_resource_group.participant.location
  allocation_method   = "Static"
}
```
