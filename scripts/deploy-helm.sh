#!/usr/bin/env bash
set -euo pipefail
APP="${APP:-demo-nginx}"
NS="${NAMESPACE:-demo-nginx}"

oc new-project "${NS}" >/dev/null 2>&1 || true
echo "[*] Installing/upgrading ${APP} via Helm in ${NS}"
helm upgrade --install "${APP}" "charts/${APP}" -n "${NS}"
echo "[✓] Helm release ready."
