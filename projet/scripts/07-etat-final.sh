#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '== HELM =='
helm status inventaire -n inventaire
helm lint chart/inventaire
helm template inventaire chart/inventaire -n inventaire \
  --set api.image.repository=inventaire-api \
  --set api.image.tag=dev >/tmp/tp4-final-chart.yaml
printf '\n== RESSOURCES ==\n'
kubectl -n inventaire get all,pvc,ingress,hpa,networkpolicy,pdb
kubectl -n inventaire get certificate,servicemonitor,prometheusrule
printf '\n== MONITORING ==\n'
kubectl -n inventaire get pods -o wide
kubectl top pods -n inventaire || true
printf '\n== CERT ==\n'
kubectl -n inventaire get certificate
printf '\n[CAPTURE 13] Etat complet des ressources avant rendu.\n'
