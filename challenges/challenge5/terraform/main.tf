provider "azurerm" {
  version = "=2.0.0"

  features {}
}

data "azurerm_resource_group" "participant" {
  name = var.resource_group
}

data "azurerm_kubernetes_cluster" "participant" {
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.participant.name
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.participant.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.participant.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.participant.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.participant.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  load_config_file = "false"

  host                   = data.azurerm_kubernetes_cluster.participant.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.participant.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.participant.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.participant.kube_config.0.cluster_ca_certificate)
}

terraform {
  required_version = "~> 0.12.0"
}
