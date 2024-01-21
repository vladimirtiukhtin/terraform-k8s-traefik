resource "kubernetes_ingress_class_v1" "traefik" {

  metadata {
    name = local.name
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = tostring(var.is_default_ingress_class)
    }
    labels = local.labels
  }

  spec {
    controller = "traefik.io/ingress-controller"
  }

}
