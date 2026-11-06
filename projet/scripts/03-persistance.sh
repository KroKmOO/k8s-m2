#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '== AVANT SUPPRESSION =='
kubectl -n inventaire get pvc
curl -skS --resolve inventaire.local:443:127.0.0.1 \
  https://inventaire.local/api/items
echo
printf '\n[CAPTURE 06A] Liste avant suppression du Pod PostgreSQL + PVC Bound.\n'
read -r -p 'Capture 06A faite ? Appuie sur Entrée pour supprimer UNIQUEMENT le Pod PostgreSQL... '
kubectl -n inventaire delete pod inventaire-postgres-0
kubectl -n inventaire rollout status statefulset/inventaire-postgres --timeout=360s
kubectl -n inventaire wait --for=condition=Ready pod/inventaire-postgres-0 --timeout=360s
kubectl -n inventaire rollout status deployment/inventaire-api --timeout=240s
printf '\n== APRES RECREATION ==\n'
kubectl -n inventaire get pvc,pods
curl -skS --resolve inventaire.local:443:127.0.0.1 \
  https://inventaire.local/api/items
echo
printf '\n[CAPTURE 06B] Article conservé + Pod postgres recréé + PVC Bound.\n'
