#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '== VERIFIER METRICS =='
kubectl top nodes
kubectl -n inventaire get hpa
printf '\n== CHARGE CPU /api/cpu?ms=200 durant 180 secondes ==\n'
printf 'Garde ce terminal visible et fais des captures HPA au moment où REPLICAS augmente.\n'
pids=()
cleanup() { for pid in "${pids[@]:-}"; do kill "$pid" 2>/dev/null || true; done; }
trap cleanup EXIT INT TERM
for i in 1 2 3 4 5 6; do
  (
    end=$((SECONDS + 180))
    while (( SECONDS < end )); do
      curl -skS --max-time 8 --resolve inventaire.local:443:127.0.0.1 \
        'https://inventaire.local/api/cpu?ms=200' >/dev/null || true
    done
  ) &
  pids+=("$!")
done
for i in $(seq 1 12); do
  sleep 15
  echo "--- Relevé $i/12 ---"
  kubectl -n inventaire get hpa
  kubectl -n inventaire get pods -l app.kubernetes.io/component=api --no-headers
  echo '[CAPTURE 09] HPA si REPLICAS > 2 ; ouvrir Grafana sur la même plage.'
done
wait "${pids[@]}" || true
printf '\n== FIN CHARGE, REPLICAS REDESCENDENT PROGRESSIVEMENT ==\n'
kubectl -n inventaire get hpa
printf '[CAPTURE 10] Prometheus Alerts : InventaireApiLatenceElevee Firing si seuil franchi et tenu.\n'
printf '[CAPTURE 11] Grafana Explore Loki : {namespace="inventaire"} |= "/api/cpu".\n'
