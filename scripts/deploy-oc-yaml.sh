#!/usr/bin/env bash
set -euo pipefail
APP="${APP:-demo-nginx}"
NS="${NAMESPACE:-demo-nginx}"
FILE="generated/k8s/${APP}/all-in-one.yaml"

oc new-project "${NS}" >/dev/null 2>&1 || true
echo "[*] Applying ${FILE} to namespace ${NS}"
oc apply -n "${NS}" -f "${FILE}"
echo "[✓] Applied."
