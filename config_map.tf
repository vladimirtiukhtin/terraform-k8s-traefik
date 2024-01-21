resource "kubernetes_config_map_v1" "traefik" {
  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = {}
    labels      = local.labels
  }
  data = var.file_configuration
}
