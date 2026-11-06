#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
if ! grep -q 'TP4 — Inventaire' README.md; then
  cat >> README.md <<'EOF'

## TP4 — Inventaire : projet final noté /20

[Consulter le TP4 et son compte rendu technique](projet/README.md) · [Commandes et captures](projet/COMMANDES_ET_CAPTURES.md) · [Dashboard Grafana](projet/grafana/golden-signals-inventaire.json).

Le TP4 reprend le cluster Kind et les services des TP1 à TP3 : Helm, frontend/API/PostgreSQL, Ingress HTTPS, NetworkPolicies et RBAC, Prometheus/Loki/Grafana, HPA et CI/CD GHCR.

[Portail Archify Atlas des TPs précédents](https://krokmoo.github.io/k8s-m2/atlas/) — la vue TP4 et ses preuves seront ajoutées après les validations réelles.
EOF
fi
printf 'README principal mis à jour.\n'
