resource "kubernetes_namespace_v1" "env" {
  for_each = var.environments

  metadata {
    name = each.key
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "idp.lab/environment"          = each.key
      "idp.lab/owner"                = each.value.owner
    }
  }
}

resource "kubernetes_resource_quota_v1" "env" {
  for_each = var.environments

  metadata {
    name      = "${each.key}-quota"
    namespace = kubernetes_namespace_v1.env[each.key].metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = each.value.cpu
      "requests.memory" = each.value.memory
      "limits.cpu"      = each.value.cpu
      "limits.memory"   = each.value.memory
      "pods"            = tostring(each.value.max_pods)
    }
  }
}

resource "kubernetes_limit_range_v1" "env" {
  for_each = var.environments

  metadata {
    name      = "${each.key}-limits"
    namespace = kubernetes_namespace_v1.env[each.key].metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default_request = {
        cpu    = var.default_container_limits.request_cpu
        memory = var.default_container_limits.request_memory
      }
      default = {
        cpu    = var.default_container_limits.limit_cpu
        memory = var.default_container_limits.limit_memory
      }
    }
  }
}
