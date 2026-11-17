locals {
  argo_repo = "https://argoproj.github.io/argo-helm"
}

resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = local.argo_repo
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [yamlencode({
    configs = {
      params = {
        "server.insecure" = true
      }
      # "backstage": API-token-only account with read-only access, used by the Backstage Argo CD plugin.
      cm = {
        "accounts.backstage" = "apiKey"
      }
      rbac = {
        "policy.csv" = "g, backstage, role:readonly"
      }
    }
    server = {
      service = {
        type         = "NodePort"
        nodePortHttp = var.node_port
      }
    }
    # Lab: no HA, no Dex.
    dex = { enabled = false }
  })]
}

# Root app (app-of-apps) installed via the argocd-apps chart, so `plan` never needs the
# Application CRD to exist up front (unlike kubernetes_manifest).
resource "helm_release" "root_app" {
  name       = "argocd-apps"
  repository = local.argo_repo
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version
  namespace  = var.namespace

  values = [yamlencode({
    applications = {
      root = {
        namespace  = var.namespace
        project    = "default"
        finalizers = ["resources-finalizer.argocd.argoproj.io"]
        source = {
          repoURL        = var.gitops_repo_url
          targetRevision = var.gitops_revision
          path           = var.gitops_path
          directory      = { recurse = true }
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = var.namespace
        }
        syncPolicy = {
          automated = {
            prune    = true
            selfHeal = true
          }
        }
      }
    }
  })]

  depends_on = [helm_release.argocd]
}
