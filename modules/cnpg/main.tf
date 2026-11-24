# CloudNativePG operator: lets each service chart declare its own PostgreSQL `Cluster`
# (postgresql.cnpg.io/v1). The operator creates the database, users and the <cluster>-app Secret,
# so no database passwords live in git or Backstage.
resource "helm_release" "cnpg" {
  name             = "cnpg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [yamlencode({
    # Lab: one operator replica, small footprint.
    replicaCount = 1
    resources = {
      requests = { cpu = "50m", memory = "128Mi" }
      limits   = { cpu = "500m", memory = "256Mi" }
    }
  })]
}
