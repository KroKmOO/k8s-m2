#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '== HTTPS AUTO-SIGNE =='
curl -skS --resolve inventaire.local:443:127.0.0.1 \
  https://inventaire.local/api/health
echo
curl -skS --resolve inventaire.local:443:127.0.0.1 \
  https://inventaire.local/api/ready
echo
curl -skS --resolve inventaire.local:443:127.0.0.1 \
  https://inventaire.local/api/items
echo
printf '\n== AJOUT ARTICLE ==\n'
curl -skS --resolve inventaire.local:443:127.0.0.1 \
  -H 'Content-Type: application/json' \
  -d '{"nom":"Article TP4 - persistance"}' \
  https://inventaire.local/api/items
echo
printf '\n== VERIFICATION ARTICLES ==\n'
curl -skS --resolve inventaire.local:443:127.0.0.1 \
  https://inventaire.local/api/items
echo
printf '\n== HTTP -> HTTPS redirection ==\n'
curl -sSI --resolve inventaire.local:80:127.0.0.1 \
  http://inventaire.local | head -15
printf '\n== ROUTE /metrics NON PUBLIEE ==\n'
curl -skS -o /dev/null -w 'HTTP /metrics: %{http_code}\n' \
  --resolve inventaire.local:443:127.0.0.1 https://inventaire.local/metrics
printf '\n[CAPTURE 04] Navigateur https://inventaire.local : ajout puis liste de l article.\n'
printf '[CAPTURE 05] curl HTTPS, redirection HTTP et certificat TLS Ready.\n'
