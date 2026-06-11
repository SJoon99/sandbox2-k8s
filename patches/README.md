# patches

Cluster-specific overrides for SmartX common apps.

This directory is intentionally empty for the initial Sandbox2 tower migration. A patch is only consumed when the corresponding `smartx-k8s/apps/*/manifest.yaml` sets one of:

```yaml
patched: true
useClusterValues: true
```

Do not use patches as an app selector. App selection is controlled by `values.yaml -> features` and SmartX `apps/*/manifest.yaml -> spec.app.features`.
