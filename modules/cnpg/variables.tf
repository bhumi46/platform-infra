variable "chart_version" {
  description = "cloudnative-pg Helm chart version (pinned)."
  type        = string
}

variable "namespace" {
  description = "Namespace for the operator."
  type        = string
  default     = "cnpg-system"
}
