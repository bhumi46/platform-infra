variable "namespace" {
  description = "Namespace for the Backstage reader ServiceAccount."
  type        = string
  default     = "backstage"
}

variable "service_account" {
  type    = string
  default = "backstage-reader"
}
