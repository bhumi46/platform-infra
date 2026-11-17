variable "namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_chart_version" {
  description = "argo/argo-cd chart version."
  type        = string
}

variable "argocd_apps_chart_version" {
  description = "argo/argocd-apps chart version."
  type        = string
}

variable "node_port" {
  description = "NodePort for the Argo CD server (mapped to localhost by kind)."
  type        = number
  default     = 30080
}

variable "gitops_repo_url" {
  description = "Git repo the root app watches."
  type        = string
}

variable "gitops_revision" {
  type    = string
  default = "main"
}

variable "gitops_path" {
  type    = string
  default = "apps"
}
