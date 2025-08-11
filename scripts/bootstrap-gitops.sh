#!/usr/bin/env bash
set -euo pipefail
APP="${APP:-demo-nginx}"
NS="${NAMESPACE:-demo-nginx}"
GIT_URL="${GIT_URL:-https://github.com/you/your-repo.git}"
GIT_PATH="${GIT_PATH:-charts/demo-nginx}"

TMP="gitops/${APP}-app.yaml.tmp"
cp gitops/${APP}-app.yaml "${TMP}"
sed -i "s#https://github.com/you/your-repo.git#${GIT_URL}#g" "${TMP}"
sed -i "s#charts/demo-nginx#${GIT_PATH}#g" "${TMP}"

echo "[*] Creating Argo CD Application (requires OpenShift GitOps operator)"
oc apply -f "${TMP}"
echo "[✓] Argo CD Application created."
