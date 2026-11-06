#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
echo '== CONTEXTE KIND =='
kubectl config use-context kind-m2-k8s
kubectl get nodes -o wide
kind get clusters
echo '== STACK ANTERIEURE =='
kubectl get ns ingress-nginx cert-manager monitoring
kubectl get clusterissuer selfsigned || true
kubectl -n monitoring get pods | head -20
kubectl -n ingress-nginx get pods
kubectl -n cert-manager get pods
echo '== OUTILS =='
for tool in docker kind kubectl helm openssl curl; do command -v "$tool"; done
echo '[CAPTURE 01] Les trois nœuds Ready et la supervision existante.'
