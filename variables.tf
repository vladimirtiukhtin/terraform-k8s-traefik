variable "name" {
  description = "Common application name"
  type        = string
  default     = "traefik"
}

variable "instance" {
  description = "Common instance name"
  type        = string
  default     = "default"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "kube-system"
}

variable "user_id" {
  description = "Unix UID to apply to persistent volume"
  type        = number
  default     = 999
}

variable "group_id" {
  description = "Unix GID to apply to persistent volume"
  type        = number
  default     = 999
}

variable "image_name" {
  description = "Image name including registry address"
  type        = string
  default     = "docker.io/traefik"
}

variable "image_tag" {
  description = "Container image tag (version)"
  type        = string
  default     = "2.10.5"
}

variable "is_default_ingress_class" {
  description = ""
  type        = bool
  default     = true
}

variable "file_configuration" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "install_crd" {
  description = ""
  type        = bool
  default     = true
}

variable "pod_annotations" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "service_annotations" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "extra_args" {
  description = ""
  type        = list(string)
  default     = []
}

variable "extra_labels" {
  description = "Any extra labels to apply to kubernetes resources"
  type        = map(string)
  default     = {}
}
