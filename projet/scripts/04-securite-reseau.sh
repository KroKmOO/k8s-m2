#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '== RBAC =='
kubectl auth can-i get pods -n inventaire --as=system:serviceaccount:inventaire:lecteur
kubectl auth can-i delete pods -n inventaire --as=system:serviceaccount:inventaire:lecteur
kubectl auth can-i get secrets -n inventaire --as=system:serviceaccount:inventaire:lecteur
kubectl auth can-i get pods -n inventaire --as=system:serviceaccount:inventaire:inventaire-api
printf '\n== POD SECURITY ==\n'
kubectl get ns inventaire --show-labels
kubectl -n inventaire get pods -o wide
printf '\n== POLITIQUES RESEAU ==\n'
kubectl -n inventaire get networkpolicy
printf '\n== FLUX API -> POSTGRES AUTORISE ==\n'
kubectl -n inventaire exec deploy/inventaire-api -- \
  node -e 'const net=require("net");const s=net.connect(5432,"inventaire-postgres");s.on("connect",()=>{console.log("OK: API -> postgres 5432");s.destroy()});s.on("error",e=>{console.error(e);process.exit(1)});setTimeout(()=>{console.error("TIMEOUT");process.exit(1)},5000).unref()'

printf '\n== TEST INTRUS (restricted) ==\n'
kubectl -n inventaire delete pod intrus --ignore-not-found=true --wait=true
kubectl apply -f tests/intrus.yaml
kubectl -n inventaire wait --for=condition=Ready pod/intrus --timeout=120s || true
sleep 6
kubectl -n inventaire logs intrus --tail=20
printf '\n[CAPTURE 07] Intrus -> PostgreSQL bloqué + API -> PostgreSQL autorisé.\n'
printf '[CAPTURE 08] RBAC can-i : lecture yes, suppression et secret no.\n'
kubectl -n inventaire delete pod intrus --ignore-not-found=true
