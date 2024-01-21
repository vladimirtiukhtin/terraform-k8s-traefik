resource "kubernetes_daemon_set_v1" "traefik" {

  metadata {
    name        = local.name
    namespace   = var.namespace
    annotations = {}
    labels      = local.labels
  }

  spec {

    selector {
      match_labels = local.selector_labels
    }

    template {

      metadata {
        annotations = var.pod_annotations
        labels      = local.labels
      }

      spec {
        service_account_name            = kubernetes_service_account_v1.traefik.metadata.0.name
        automount_service_account_token = true

        container {
          name              = var.name
          image             = "${var.image_name}:${var.image_tag}"
          image_pull_policy = var.image_tag == "latest" ? "Always" : "IfNotPresent"
          args = compact(concat([
            "--log=true",
            "--log.level=debug",
            "--entrypoints.http",
            "--entrypoints.https",
            "--entrypoints.traefik",
            "--entrypoints.traefik.address=:8080",
            "--entrypoints.http.address=:8000",
            "--entrypoints.https.address=:8443",
            "--entrypoints.https.http.tls=true",
            "--api=true",
            "--api.dashboard=true",
            "--providers.kubernetesingress=true",
            "--providers.kubernetesingress.ingressclass=${kubernetes_ingress_class_v1.traefik.metadata.0.name}",
            "--providers.kubernetescrd",
            "--providers.file.directory=/etc/traefik",
            "--providers.file.watch=true",
            "--ping",
            "--ping.entrypoint=traefik",
            "--serversTransport.insecureSkipVerify=true" // ToDo: fix this
          ], var.extra_args))

          port {
            name           = "traefik"
            protocol       = "TCP"
            container_port = 8080
          }

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = 8000
          }

          port {
            name           = "https"
            protocol       = "TCP"
            container_port = 8443
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          readiness_probe {
            period_seconds        = 5
            initial_delay_seconds = 3
            success_threshold     = 1
            failure_threshold     = 3
            timeout_seconds       = 3

            http_get {
              scheme = "HTTP"
              port   = "traefik"
              path   = "/ping"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/traefik"
            read_only  = true
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }
        }

        volume {
          name = "config"
          config_map {
            name         = kubernetes_config_map_v1.traefik.metadata.0.name
            default_mode = "0420"
          }
        }

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }

      }

    }

  }
  depends_on = [
    kubernetes_cluster_role_binding_v1.traefik
  ]
}
