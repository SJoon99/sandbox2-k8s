# Sandbox2 full SmartX tower bootstrap plan

Sandbox2 is the clean preset repo for the full SmartX tower path.

## Why a new repo?

`Sandbox-k8s` can probably be made to work, especially because GitHub is generally case-insensitive for repository paths. But it already contains Phase A bridge experiments that patch individual SmartX Applications into the manually installed `argocd` namespace.

`sandbox2-k8s` starts clean and matches the SmartX naming formula exactly:

```text
cluster.name = sandbox2
cluster repo = https://github.com/SJoon99/sandbox2-k8s.git
```

## Required companion repo

The current SmartX template uses one `repo` block for both framework and cluster repo derivation:

```text
framework repo = {{ repo.baseUrl }}/{{ repo.owner }}/{{ repo.name }}.git
cluster repo   = {{ repo.baseUrl }}/{{ repo.owner }}/{{ cluster.name }}-k8s.git
```

Sandbox2 values therefore target:

```yaml
repo:
  baseUrl: https://github.com
  owner: SJoon99
  name: smartx-k8s
cluster:
  name: sandbox2
```

This means full tower apply requires:

```text
https://github.com/SJoon99/smartx-k8s.git
https://github.com/SJoon99/sandbox2-k8s.git
```

`SJoon99/sandbox2-k8s` exists. `SJoon99/smartx-k8s` still needs to be created as a fork/mirror of upstream SmartX before applying the root app-of-apps.

## Current feature target

```yaml
features:
  - org.ulagbulag.io/gitops
```

Render-only output currently produces:

| Application | Meaning | Apply now? |
|---|---|---|
| `sandbox2` | root app-of-apps | not yet |
| `sandbox2-argo-cd` | target SmartX Argo CD in `argo` | not yet |
| `sandbox2-cilium` | CNI app pulled through `gitops -> git -> cni`, autoSync false | not yet |
| `sandbox2-kubelet-csr-approver` | baseline app | only after target Argo prerequisites |

## Migration sequence

1. Create/fork `SJoon99/smartx-k8s`.
2. Render `features: org.ulagbulag.io/gitops` and confirm repo URLs are:
   - `https://github.com/SJoon99/smartx-k8s.git`
   - `https://github.com/SJoon99/sandbox2-k8s.git`
3. Bootstrap target namespace `argo`.
4. Install or let SmartX install Argo CD into namespace `argo`.
5. Create target `AppProject/sandbox2-ops`.
6. Register in-cluster destination as Argo cluster name `sandbox2`.
7. Apply root Application `sandbox2` to namespace `argo`.
8. Migrate/retire old bridge Applications in namespace `argocd` only after target Argo is healthy.

## Safety rule

Do not blindly sync `sandbox2-cilium`. It is rendered because `gitops` requires `git`, which requires `cni`; SmartX marks Cilium `autoSync: false` for a reason.
