# 1 control plane + 1 worker. NodePort 30080 (Argo CD) is published on localhost:<argocd_host_port>.
resource "kind_cluster" "this" {
  name            = var.name
  node_image      = var.node_image
  kubeconfig_path = var.kubeconfig_path
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 30080
        host_port      = var.argocd_host_port
        protocol       = "TCP"
      }
    }

    node {
      role = "worker"
    }
  }
}
