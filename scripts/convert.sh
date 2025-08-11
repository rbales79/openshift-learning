#!/usr/bin/env bash
set -euo pipefail

APP="${APP:-demo-nginx}"
COMPOSE="apps/${APP}/docker-compose.yaml"
OUTDIR="generated/k8s/${APP}"
OUTFILE="${OUTDIR}/all-in-one.yaml"

mkdir -p "${OUTDIR}"

if ! command -v kompose >/dev/null 2>&1; then
  echo "kompose not found. Install from https://kompose.io/"
  exit 1
fi

echo "[*] Converting ${COMPOSE} to ${OUTFILE}"
kompose convert -f "${COMPOSE}" --out "${OUTFILE}"

# Optional: turn manifests into a Helm chart using helmify if present
if command -v helmify >/dev/null 2>&1; then
  echo "[*] helmify detected; generating Helm chart from manifests"
  helmify "charts/${APP}" "${OUTFILE}"
else
  echo "[*] helmify not found; using example chart at charts/${APP} (edit as needed)"
fi

echo "[✓] Done."
