#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SMARTX_DIR=${SMARTX_DIR:-/home/joon/repo_study/scalex/repo_ref/smartx-k8s}
OUT_DIR=${OUT_DIR:-${ROOT_DIR}/docs/generated/gitops-render}
mkdir -p "${OUT_DIR}"

helm template sandbox2-smartx "${SMARTX_DIR}" \
  -f "${ROOT_DIR}/values.yaml" \
  -s templates/applications.yaml \
  > "${OUT_DIR}/render.yaml"

python3 - "${OUT_DIR}/render.yaml" "${OUT_DIR}/summary.tsv" <<'PY'
import sys, yaml
render, out = sys.argv[1:]
with open(out, 'w') as f:
    f.write('argoNamespace\tname\tproject\tdestNamespace\tdestName\tdestServer\tautomated\tchartOrPath\trepo\trevision\n')
    for doc in yaml.safe_load_all(open(render)):
        if not (isinstance(doc, dict) and doc.get('kind') == 'Application'):
            continue
        meta = doc.get('metadata', {})
        spec = doc.get('spec', {})
        sources = spec.get('sources') or ([spec.get('source')] if spec.get('source') else [])
        first = sources[0] if sources else {}
        dest = spec.get('destination') or {}
        f.write('\t'.join(str(x or '') for x in [
            meta.get('namespace'), meta.get('name'), spec.get('project'), dest.get('namespace'), dest.get('name'), dest.get('server'),
            bool(spec.get('syncPolicy', {}).get('automated')), first.get('chart') or first.get('path'), first.get('repoURL'), first.get('targetRevision')
        ]) + '\n')
PY

echo "Wrote ${OUT_DIR}/render.yaml"
echo "Wrote ${OUT_DIR}/summary.tsv"
