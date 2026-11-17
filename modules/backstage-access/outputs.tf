output "token" {
  description = "ServiceAccount token for the Backstage Kubernetes plugin."
  value       = kubernetes_secret_v1.reader_token.data["token"]
  sensitive   = true
}
