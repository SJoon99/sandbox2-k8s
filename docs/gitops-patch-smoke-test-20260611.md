# Sandbox2 gitops feature patch smoke test — 2026-06-11

## Purpose

Verify `patches/` with an app that actually belongs to the `org.ulagbulag.io/gitops` feature: `sandbox2-argo-cd`.

## Required SmartX fork change

`SJoon99/smartx-k8s` commit:

```text
1c14f5b fix(argocd): enable cluster patches
```

Changed:

```yaml
# apps/argo-cd/manifest.yaml
spec:
  app:
    patched: true
```

## Sandbox2 patch

```yaml
# patches/argo-cd/values.yaml
configs:
  cm:
    sandbox2.patch.smoke: "argo-cd"
```

This is intentionally harmless: it adds a custom key to `argocd-cm` and proves the patch value file is consumed.

Expected child Application value files:

```text
$origin/apps/argo-cd/values.yaml
$cluster/patches/argo-cd/values.yaml
```

Expected cluster effect:

```bash
kubectl -n argo get cm argocd-cm \
  -o jsonpath='{.data.sandbox2\.patch\.smoke}{"\n"}'
```

Expected output:

```text
argo-cd
```

## Observed result

Patch propagation succeeded for the real `org.ulagbulag.io/gitops` app `sandbox2-argo-cd`.

```text
Application sandbox2-argo-cd: Synced / Healthy
ConfigMap argocd-cm key: sandbox2.patch.smoke=argo-cd
```

Observed commands:

```bash
kubectl -n argo get application sandbox2-argo-cd -o wide
kubectl -n argo get application sandbox2-argo-cd -o yaml \
  | grep -A8 'valueFiles:'
kubectl -n argo get cm argocd-cm \
  -o jsonpath='{.data.sandbox2\\.patch\\.smoke}{"\\n"}'
kubectl -n argo rollout status deploy/argo-cd-argocd-server --timeout=60s
```

Observed output:

```text
argo-cd
```
