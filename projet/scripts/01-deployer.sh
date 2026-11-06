#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
kubectl config use-context kind-m2-k8s

echo '== METRICS-SERVER pour le HPA =='
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ --force-update
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  -n kube-system --set 'args={--kubelet-insecure-tls}' \
  --wait --timeout 10m

echo '== NAMESPACE RESTRICTED =='
kubectl get ns inventaire >/dev/null 2>&1 || kubectl create ns inventaire
kubectl label ns inventaire pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted --overwrite

echo '== EMETTEUR AUTOSIGNE (LAB UNIQUEMENT) =='
kubectl apply -f bootstrap/clusterissuer.yaml

echo '== SECRET POSTGRESQL HORS GIT =='
if kubectl -n inventaire get secret inventaire-postgres-auth >/dev/null 2>&1; then
  echo 'Secret déjà présent : conservation du mot de passe de la base existante.'
else
  PG_PASSWORD="$(openssl rand -hex 24)"
  kubectl -n inventaire create secret generic inventaire-postgres-auth \
    --from-literal="POSTGRES_PASSWORD=${PG_PASSWORD}"
  unset PG_PASSWORD
  echo 'Secret généré aléatoirement dans Kubernetes, non sauvegardé dans Git.'
fi

echo '== IMAGE DOCKER LOCALE =='
docker build -t inventaire-api:dev ./app
kind load docker-image inventaire-api:dev --name m2-k8s

echo '== HELM LINT + TEMPLATE =='
helm lint ./chart/inventaire
helm template inventaire ./chart/inventaire -n inventaire \
  --set api.image.repository=inventaire-api \
  --set api.image.tag=dev > /tmp/tp4-inventaire-rendered.yaml

echo '== HELM DEPLOIEMENT LOCAL =='
helm upgrade --install inventaire ./chart/inventaire \
  -n inventaire --create-namespace \
  --set api.image.repository=inventaire-api \
  --set api.image.tag=dev \
  --wait --timeout 12m

echo '== RESSOURCES =='
kubectl -n inventaire get all,pvc,ingress,hpa,networkpolicy,pdb
kubectl -n inventaire get certificate
kubectl -n inventaire get pods -o wide
helm status inventaire -n inventaire
printf '\n[CAPTURE 02] helm STATUS deployed + Kubernetes ressources + Pods Running + PVC Bound.\n'
printf '[CAPTURE 03] namespace inventaire étiqueté restricted, security contexts des Pods.\n'
