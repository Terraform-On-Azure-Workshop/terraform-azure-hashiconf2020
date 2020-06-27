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

resource "kubernetes_service" "gateway" {
  metadata {
    name = "gateway"
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-resource-group" = data.azurerm_resource_group.participant.name
    }
  }

  spec {
    selector = {
      app       = "consul"
      component = "mesh-gateway"
    }

    session_affinity = "ClientIP"

    port {
      port        = 443
      target_port = 8443
    }

    type             = "LoadBalancer"
    load_balancer_ip = azurerm_public_ip.gateway.ip_address
  }
}
