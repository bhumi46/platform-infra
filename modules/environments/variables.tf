variable "environments" {
  description = "Map of env name => settings, usually loaded from envs/<x>/environments/*.yaml."
  type = map(object({
    owner    = string
    cpu      = string
    memory   = string
    max_pods = number
  }))
}

variable "default_container_limits" {
  description = "LimitRange defaults so pods without resources still fit the quota."
  type = object({
    request_cpu    = string
    request_memory = string
    limit_cpu      = string
    limit_memory   = string
  })
  default = {
    request_cpu    = "50m"
    request_memory = "64Mi"
    limit_cpu      = "250m"
    limit_memory   = "256Mi"
  }
}
