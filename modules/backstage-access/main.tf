# Read-only identity for the Backstage Kubernetes plugin. Backstage never writes to the cluster.
resource "kubernetes_namespace_v1" "this" {
  metadata {
    name   = var.namespace
    labels = { "app.kubernetes.io/managed-by" = "terraform" }
  }
}

resource "kubernetes_service_account_v1" "reader" {
  metadata {
    name      = var.service_account
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

# Long-lived token for the ServiceAccount (lab only; prefer short-lived tokens in production).
resource "kubernetes_secret_v1" "reader_token" {
  metadata {
    name      = "${var.service_account}-token"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.reader.metadata[0].name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

# What the Backstage Kubernetes plugin reads.
resource "kubernetes_cluster_role_v1" "reader" {
  metadata {
    name = "backstage-reader"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "services", "configmaps", "limitranges", "resourcequotas"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "reader" {
  metadata {
    name = "backstage-reader"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.reader.metadata[0].name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}
