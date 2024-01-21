resource "kubernetes_manifest" "traefik_crd" {
  for_each = {
    for document in local.crd : document["metadata"]["name"] => document if var.install_crd
  }
  manifest = each.value
}

locals {
  crd = [for document in compact(split("---", file("${path.module}/resources/crd.yaml"))) :
    yamldecode(trimspace(document))
  ]
}
