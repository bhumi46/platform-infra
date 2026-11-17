locals {
  kubeconfig_path = abspath("${path.module}/.kube/${var.cluster_name}.yaml")

  # Adding an environment = adding one YAML file in ./environments (this is what the
  # Backstage "New environment" template opens a PR for).
  environments = {
    for f in fileset("${path.module}/environments", "*.yaml") :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/environments/${f}"))
  }
}

module "cluster" {
  source = "../../modules/kind-cluster"

  name             = var.cluster_name
  node_image       = var.node_image
  kubeconfig_path  = local.kubeconfig_path
  argocd_host_port = var.argocd_host_port
}

provider "kubernetes" {
  host                   = module.cluster.endpoint
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host                   = module.cluster.endpoint
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}

module "environments" {
  source = "../../modules/environments"

  environments = local.environments
}

module "argocd" {
  source = "../../modules/argocd"

  argocd_chart_version      = var.argocd_chart_version
  argocd_apps_chart_version = var.argocd_apps_chart_version
  gitops_repo_url           = var.gitops_repo_url
}
