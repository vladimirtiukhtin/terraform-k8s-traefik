K8S Traefik Terraform module
============================

# Example for AWS
```hcl
module "aws_traefik" {
  source = "./modules/k8s_traefik"
  for_each = {
    internal = { internal = true, default = true }
    external = { internal = false, default = false }
  }
  instance                 = each.key
  is_default_ingress_class = each.value["default"]
  extra_args = [
    "--metrics.prometheus=true",
    "--metrics.prometheus.addrouterslabels=true",
    "--entrypoints.http.proxyprotocol=true",
    "--entrypoints.http.proxyprotocol.trustedips=${module.aws_network.vpc_ipv4_cidr}",
    "--entrypoints.http.http.middlewares=whitelist@file,redirect@file",
    "--entrypoints.https.proxyprotocol=true",
    "--entrypoints.https.proxyprotocol.trustedips=${module.aws_network.vpc_ipv4_cidr}",
    "--entrypoints.https.http.middlewares=whitelist@file,compress@file"
  ]
  service_annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-type"           = "nlb"
    "service.beta.kubernetes.io/aws-load-balancer-internal"       = tostring(each.value["internal"])
    "service.beta.kubernetes.io/aws-load-balancer-proxy-protocol" = "*"
    "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = join(",", [
      "Environment=${var.environment}",
      "kubernetes.io/ingress-class=traefik-${each.key}"
    ])
  }
  pod_annotations = {
    "prometheus.io/scrape" = "true"
  }
}
```

# Example for Hetzner
```hcl
module "hcloud_traefik" {
  source = "./modules/k8s_traefik"
  extra_args = [
    "--metrics.prometheus=true",
    "--metrics.prometheus.addrouterslabels=true",
    "--entrypoints.http.proxyprotocol=true",
    "--entrypoints.http.proxyprotocol.trustedips=${module.hcloud_network.vpc_ipv4_cidr}",
    "--entrypoints.http.http.middlewares=whitelist@file,redirect@file",
    "--entrypoints.https.proxyprotocol=true",
    "--entrypoints.https.proxyprotocol.trustedips=${module.hcloud_network.vpc_ipv4_cidr}",
    "--entrypoints.https.http.middlewares=whitelist@file,compress@file"
  ]
  file_configuration =  {
    "middlewares.yml" = yamlencode({
      http = {
        middlewares = {
          redirect = {
            redirectScheme = {
              scheme    = "https"
              permanent = true
            }
          }
          compress = {
            compress = {}
          }
          whitelist = {
            ipWhiteList = {
              sourceRange = [
                "10.0.0.0/8"
              ]
            }
          }
        }
      }
    })
  }
  service_annotations = {
    "load-balancer.hetzner.cloud/location"               = "fsn1"
    "load-balancer.hetzner.cloud/use-private-ip"         = "true"
    "load-balancer.hetzner.cloud/uses-proxyprotocol"     = "true"
    "load-balancer.hetzner.cloud/disable-public-network" = "false"
  }
  pod_annotations = {
    "prometheus.io/scrape" = "true"
  }
}

data "hcloud_load_balancer" "traefik" {
  with_selector = "hcloud-ccm/service-uid=${module.hcloud_traefik.service_uid}"
}
```
