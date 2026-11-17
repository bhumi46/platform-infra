variable "cluster_name" {
  type    = string
  default = "idp-lab"
}

variable "node_image" {
  description = "Pinned to the default image of kind v0.33.0."
  type        = string
  default     = "kindest/node:v1.37.0@sha256:a1ed56cfb0e7b93589bdf97c8cd566405a265939e3620fc4f5de89adff580ae5"
}

variable "argocd_host_port" {
  type    = number
  default = 8080
}

variable "argocd_chart_version" {
  type    = string
  default = "10.18.0"
}

variable "argocd_apps_chart_version" {
  type    = string
  default = "2.0.8"
}

variable "gitops_repo_url" {
  type    = string
  default = "https://github.com/bhumi46/gitops.git"
}
