output "kubeconfig_path" {
  value = module.cluster.kubeconfig_path
}

output "argocd_url" {
  value = "http://localhost:${var.argocd_host_port}"
}

output "argocd_admin_password_cmd" {
  value = "kubectl --kubeconfig ${module.cluster.kubeconfig_path} -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
}

output "environments" {
  value = module.environments.namespaces
}
