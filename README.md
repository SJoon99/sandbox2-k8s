# sandbox2-k8s

Clean Sandbox2 SmartX preset repo for the full SmartX tower migration path.

This repo intentionally follows the SmartX cluster repo naming convention:

```text
cluster.name = sandbox2
cluster repo = SJoon99/sandbox2-k8s
```

The companion SmartX framework fork is available as:

```text
SJoon99/smartx-k8s
```

## Render-only check

```bash
cd /home/joon/sandbox2-k8s
./scripts/render-gitops.sh
column -t -s $'\t' docs/generated/gitops-render/summary.tsv
```

## Docs

- [GitOps feature patch smoke test result](docs/gitops-patch-smoke-test-20260611.md)
- [Patch smoke test result](docs/patch-smoke-test-20260611.md)
- [Target Argo bootstrap result](docs/target-argo-bootstrap-result-20260611.md)
- [Full tower bootstrap plan](docs/full-tower-bootstrap-plan.md)
