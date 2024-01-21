output "namespace" {
  value = var.namespace
}

output "service_name" {
  value = kubernetes_service_v1.traefik.metadata.0.name
}

output "service_uid" {
  value = kubernetes_service_v1.traefik.metadata.0.uid
}
