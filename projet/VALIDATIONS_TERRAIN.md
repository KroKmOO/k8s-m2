# TP4 — Validations terrain et état du projet Inventaire

**Date des preuves : 6 novembre 2026.** Ce document complète le README du projet et distingue les démonstrations réellement réalisées des critères non encore établis.

## Architecture déployée

- Cluster Kind `m2-k8s`, trois nœuds ; ingress-nginx, cert-manager, Prometheus/Grafana/Loki/Fluent Bit réutilisés des TP précédents.
- Namespace `inventaire` avec Pod Security Admission en mode `restricted` ; ressources applicatives créées par le chart Helm `inventaire`.
- Frontend Nginx non privilégié (2 Pods), API Node.js (2 Pods observés), PostgreSQL StatefulSet (1 Pod), PVC `data-inventaire-postgres-0` de **1 Gio**, certificat TLS `inventaire-tls` en état Ready.
- ServiceMonitor, PrometheusRule, HPA, PDB, NetworkPolicies et rôle `lecteur` définis dans les templates du chart.

## Tableau de validations

| Contrôle | Résultat observé | Preuve |
|---|---|---|
| Précontrôle Kind et supervision | Nœuds Ready, monitoring Running | `captures/01-cluster-preflight.png` |
| Helm / Workloads / TLS | Release `inventaire` `deployed`, API 2 Pods, Frontend 2 Pods, PostgreSQL 1 Pod, TLS Ready | `captures/02-deploiement-helm.png` |
| Application HTTPS | Page Inventaire visible avec articles `test`, `test2`, `Article TP4 - persistance` | `captures/03-application-https.png` |
| Persistance PostgreSQL | PVC Bound 1 Gio ; mêmes articles avant/après suppression du Pod `inventaire-postgres-0` | `captures/04-persistance-avant.png`, `captures/05-persistance-apres.png` |
| RBAC | `kubectl auth can-i` : `yes` pour lecture, `no` pour opération interdite | `captures/06-rbac-lecteur.png` |
| Test HPA | CPU affiché à 8 %, puis 37 %, pour une cible 60 %. Nombre de réplicas : **2** | `captures/07-hpa-charge.png` |
| Centralisation des logs | Requête Loki `{namespace="inventaire"} |= "/api/cpu"` retourne des événements | `captures/08-loki-logs-cpu.png` |
| Rollback Helm | Upgrade du frontend 2 → 3, rollback révision 1, retour à 2 réplicas ; révision 3 deployed | `captures/09-helm-rollback.png` |

## Points encore à valider (sans preuve sur ces captures)

1. **HPA** : le test de charge n'a pas fait monter les réplicas au-delà de 2 ; il faut prolonger ou paralléliser la charge et obtenir une capture de `REPLICAS > 2`.
2. **NetworkPolicies** : l'essai `can-i` prouve le RBAC, pas l'isolation réseau. Fournir un test de flux autorisé et un test de flux interdit.
3. **Alerte Inventaire** : montrer la PrometheusRule TP4 en état `FIRING`, puis l'événement dans Alertmanager.
4. **CI/CD** : premier push du dossier `projet/app/` ; vérifier le workflow GH Actions, Trivy, image GHCR et mise à jour automatique du tag. Ne pas publier de secrets.
5. **Nouvelle installation depuis cluster vide** : non démontrée ; la séance a réutilisé les composants installés aux TP1 à 3.

## Commandes de validation finale

```bash
kubectl get nodes
helm lint projet/chart/inventaire
kubectl get deployments,statefulsets,pvc,certificate,ingress,hpa,networkpolicy -n inventaire
helm history inventaire -n inventaire
kubectl auth can-i get pods --as=system:serviceaccount:inventaire:lecteur -n inventaire
kubectl auth can-i delete pods --as=system:serviceaccount:inventaire:lecteur -n inventaire
```

> La persistance sur PVC prouve le maintien de données malgré une recréation de Pod, pas une sauvegarde restaurable.

[Atlas TP4 — architecture & preuves](https://krokmoo.github.io/k8s-m2/atlas/) · [Source Helm](chart/inventaire/) · [Dashboard Grafana](grafana/golden-signals-inventaire.json)
