#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '== REVISION COURANTE =='
current="$(helm status inventaire -n inventaire -o json | python3 -c 'import json,sys;print(json.load(sys.stdin)["version"])')"
echo "Revision initiale : $current"
helm upgrade inventaire ./chart/inventaire -n inventaire \
  --reuse-values --set frontend.replicas=3 --wait --timeout 8m
helm history inventaire -n inventaire
kubectl -n inventaire get deployment inventaire-frontend
printf '\n[CAPTURE 12A] Helm upgrade avec frontend 3 replicas.\n'
helm rollback inventaire "$current" -n inventaire --wait --timeout 8m
helm history inventaire -n inventaire
kubectl -n inventaire get deployment inventaire-frontend
printf '\n[CAPTURE 12B] Helm rollback et retour à 2 réplicas.\n'
