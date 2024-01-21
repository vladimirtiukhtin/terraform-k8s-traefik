resource "kubernetes_service_account_v1" "traefik" {

  metadata {
    name      = local.name
    namespace = var.namespace
    labels    = merge(local.common_labels, var.extra_labels)
  }

}

resource "kubernetes_cluster_role_v1" "traefik" {

  metadata {
    name   = local.name
    labels = merge(local.common_labels, var.extra_labels)
  }

  rule {
    api_groups = [""]
    resources = [
      "services",
      "endpoints",
      "secrets"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io"
    ]
    resources = [
      "ingresses",
      "ingressclasses"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io"
    ]
    resources = [
      "ingresses/status"
    ]
    verbs = [
      "update"
    ]
  }

  rule {
    api_groups = [
      "traefik.io",
      "traefik.containo.us"
    ]
    resources = [
      "middlewares",
      "middlewaretcps",
      "ingressroutes",
      "traefikservices",
      "ingressroutetcps",
      "ingressrouteudps",
      "tlsoptions",
      "tlsstores",
      "serverstransports"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }

}

resource "kubernetes_cluster_role_binding_v1" "traefik" {

  metadata {
    name   = local.name
    labels = merge(local.common_labels, var.extra_labels)
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.traefik.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.traefik.metadata.0.name
    namespace = var.namespace
  }

}
