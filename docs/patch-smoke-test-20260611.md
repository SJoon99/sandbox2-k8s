# Sandbox2 patch smoke test — 2026-06-11

## Purpose

Verify that cluster-specific values under `sandbox2-k8s/patches/*` are consumed by a SmartX common app.

## Required SmartX fork change

The upstream-style SmartX app manifest must opt in to cluster patches. For this test, the fork `SJoon99/smartx-k8s` was changed at:

```text
2eaf139 fix(kubelet): enable cluster patches
```

The change was:

```yaml
# apps/kubelet-csr-approver/manifest.yaml
spec:
  app:
    patched: true
```

Without `patched: true`, files under `sandbox2-k8s/patches/kubelet-csr-approver/` are ignored by the SmartX application template.

## Sandbox2 patch

```yaml
# patches/kubelet-csr-approver/values.yaml
podLabels:
  sandbox2.smartx.patch/sample: "kubelet-csr-approver"
```

Expected rendered child Application source:

```text
$cluster/patches/kubelet-csr-approver/values.yaml
```

Expected cluster effect:

```bash
kubectl -n kube-system get deploy kubelet-csr-approver \
  -o jsonpath='{.spec.template.metadata.labels.sandbox2\.smartx\.patch/sample}'
```

Expected output:

```text
kubelet-csr-approver
```

## Verification commands

```bash
cd /home/joon/sandbox2-k8s
./scripts/render-gitops.sh

grep -n 'patches/kubelet-csr-approver/values.yaml' docs/generated/gitops-render/render.yaml

kubectl -n argo annotate application sandbox2 argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argo get application sandbox2-kubelet-csr-approver -o yaml \
  | grep -A8 'valueFiles:'

kubectl -n kube-system get deploy kubelet-csr-approver \
  -o jsonpath='{.spec.template.metadata.labels.sandbox2\.smartx\.patch/sample}{"\n"}'
```

## Observed result

Patch propagation succeeded.

```text
Application sandbox2-kubelet-csr-approver: Synced / Healthy
Deployment label: sandbox2.smartx.patch/sample=kubelet-csr-approver
Pods rolled out with the same label.
```

Observed commands:

```bash
kubectl -n argo get application sandbox2-kubelet-csr-approver -o wide
kubectl -n kube-system get deploy kubelet-csr-approver \
  -o jsonpath='{.spec.template.metadata.labels.sandbox2\\.smartx\\.patch/sample}{"\\n"}'
kubectl -n kube-system get pods -l app.kubernetes.io/name=kubelet-csr-approver --show-labels
```

Observed pod labels included:

```text
sandbox2.smartx.patch/sample=kubelet-csr-approver
```
