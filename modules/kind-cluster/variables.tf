variable "name" {
  description = "Name of the kind cluster."
  type        = string
}

variable "node_image" {
  description = "Pinned kindest/node image (tag@digest)."
  type        = string
}

variable "kubeconfig_path" {
  description = "Where to write the kubeconfig for this cluster."
  type        = string
}

variable "argocd_host_port" {
  description = "Host port mapped to the Argo CD NodePort (30080)."
  type        = number
  default     = 8080
}
