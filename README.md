# platform-infra

IDP lab: Terraform for the kind cluster, environments and Argo CD bootstrap.

## Usage

```sh
cd envs/local
terraform init
terraform apply
export KUBECONFIG="$(terraform output -raw kubeconfig_path)"
kubectl get ns                                 # argocd, dev, staging, ...
eval "$(terraform output -raw argocd_admin_password_cmd)"   # admin password
open "$(terraform output -raw argocd_url)"      # http://localhost:8080, user admin
```

Tear down: `terraform destroy`.

## Layout

```
modules/kind-cluster/   kind cluster: 1 control plane + 1 worker, NodePort 30080 -> localhost:8080
modules/environments/   per env: Namespace + ResourceQuota + LimitRange
modules/argocd/         argo-cd chart (insecure, NodePort) + argocd-apps chart with the "root" app
envs/local/             wires the modules; environments/*.yaml = one file per environment
```

## Backstage access (read-only)

`modules/backstage-access` creates ServiceAccount `backstage/backstage-reader` with a get/list/watch-only ClusterRole, and a token Secret. `modules/argocd` adds an API-token-only Argo CD account `backstage` with `role:readonly`. Backstage reads them via:

```sh
terraform output -raw kube_api_url
terraform output -raw backstage_k8s_sa_token   # sensitive
```

`backstage/scripts/cluster-tokens.sh` copies these (plus a fresh Argo CD token) into `backstage/.env` without printing them.

## Adding an environment

Add `envs/local/environments/<env>.yaml` and run `terraform apply`:

```yaml
owner: platform-team   # Backstage group
cpu: "2"               # quota: requests.cpu and limits.cpu
memory: 4Gi            # quota: requests.memory and limits.memory
max_pods: 20
```

The Backstage "New environment" template opens a PR that adds exactly this file. Backstage never runs Terraform.

## Pinned versions

| What | Version |
|---|---|
| Terraform | 1.8.5 (`>= 1.6` required) |
| Provider `tehcyx/kind` | 0.13.0 |
| Provider `hashicorp/kubernetes` | 3.5.0 |
| Provider `hashicorp/helm` | 3.3.0 |
| kind CLI (local) | v0.33.0 |
| Node image | `kindest/node:v1.37.0@sha256:a1ed56cfb0e7b93589bdf97c8cd566405a265939e3620fc4f5de89adff580ae5` |
| Chart `argo/argo-cd` | 10.18.0 (Argo CD v3.6.1) |
| Chart `argo/argocd-apps` | 2.0.8 |
| Action `actions/checkout` | v7.0.1 |
| Action `hashicorp/setup-terraform` | v4.0.1 |
| Runner | `ubuntu-24.04` |

## CI

`.github/workflows/terraform.yml`:
- **PR:** `terraform fmt -check`, `init -backend=false`, `validate`.
- **Push to main:** the same, then `apply` on a throwaway kind cluster inside the runner, a smoke test (`kubectl get ns/pods`, root app exists), then `destroy`. Hosted runners can't reach a laptop; for a real cluster use plan-on-PR / apply-on-merge with a remote backend or a self-hosted runner.
