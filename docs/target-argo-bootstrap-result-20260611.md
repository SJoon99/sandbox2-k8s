# Target SmartX Argo bootstrap result — 2026-06-11

## Result

The previous manual Argo CD namespace `argocd` was backed up and removed. A target SmartX-style Argo CD control plane was installed in namespace `argo`, then the full SmartX root app-of-apps for Sandbox2 was applied.

## Backup

Old `argocd` namespace resources were backed up before deletion:

```text
/home/joon/argocd-before-sandbox2-20260611T032120Z
```

## Applied target structure

```text
namespace: argo
project: sandbox2-ops
cluster destination name: sandbox2
root Application: sandbox2
```

Rendered/seeded bootstrap files:

```text
docs/generated/bootstrap/argo-cd-valuesobject.yaml
docs/generated/bootstrap/sandbox2-argo-scheduling-overrides.yaml
docs/generated/bootstrap/sandbox2-ops-appproject.yaml
docs/generated/bootstrap/sandbox2-cluster-secret.yaml
docs/generated/bootstrap/sandbox2-root-application.yaml
```

## Important deviation for this test cluster

The SmartX Argo CD values expect nodes labeled like:

```text
node-role.kubernetes.io/kiss=Compute
node-role.kubernetes.io/kiss=ControlPlane
node-role.kubernetes.io/kiss=Gateway
```

This cluster did not have those KISS labels, so the Argo CD pods initially could not schedule. For this test, `node2` was labeled:

```bash
kubectl label node node2 node-role.kubernetes.io/kiss=Compute --overwrite
```

This is consistent with the eventual KISS/SmartX model, but it is still a manual lab step in the current cluster.

## Commands used

Install target Argo CD into `argo` using the SmartX-rendered Argo CD values:

```bash
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install argo-cd argoproj/argo-cd \
  --version 9.3.7 \
  -n argo \
  --set crds.install=false \
  -f /home/joon/repo_study/scalex/repo_ref/smartx-k8s/apps/argo-cd/values.yaml \
  -f docs/generated/bootstrap/argo-cd-valuesobject.yaml \
  -f docs/generated/bootstrap/sandbox2-argo-scheduling-overrides.yaml \
  --wait --timeout 10m
```

Seed SmartX target project/cluster/root app:

```bash
kubectl apply -f docs/generated/bootstrap/sandbox2-ops-appproject.yaml
kubectl apply -f docs/generated/bootstrap/sandbox2-cluster-secret.yaml
kubectl apply -f docs/generated/bootstrap/sandbox2-root-application.yaml
```

## Verification

```bash
kubectl -n argo get pods,deploy -o wide
kubectl -n argo get applications.argoproj.io -o wide
kubectl -n argo get application sandbox2 -o json \
  | jq '{sync:.status.sync.status, health:.status.health.status, operation:.status.operationState.phase, resources:.status.resources}'
```

Observed state:

```text
sandbox2                        Synced    Healthy
sandbox2-argo-cd                Synced    Healthy
sandbox2-kubelet-csr-approver   Synced    Healthy
sandbox2-cilium                 OutOfSync Missing
```

`sandbox2-cilium` is expected to remain unsynced for now because the SmartX Cilium manifest has `autoSync: false`. Do not sync it manually until CNI migration is explicitly planned.

## Current access

Port-forward the target Argo CD server:

```bash
kubectl -n argo port-forward svc/argo-cd-argocd-server 8080:80
```

The SmartX values disable local admin login. Access configuration/OIDC remains future work.
