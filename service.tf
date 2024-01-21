resource "kubernetes_service_v1" "traefik" {

  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = var.service_annotations
    labels      = local.labels
  }

  spec {
    type                    = "LoadBalancer"
    external_traffic_policy = "Local"

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = "https"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "http"
    }

    selector = local.selector_labels

  }

}
