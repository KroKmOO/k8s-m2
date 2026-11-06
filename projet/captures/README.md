# Plan de captures TP4

**Prendre les captures après exécution réelle** : ne pas confondre l'architecture cible avec les résultats observés.

| N° | Capture | Moment / preuve |
|---|---|---|
| 01 | `01-nodes-et-prerequis.png` | Script 00 : nœuds Ready, monitoring/ingress existants |
| 02 | `02-helm-pods-pvc.png` | Script 01 : Helm deployed, Deployments, StatefulSet, PVC Bound |
| 03 | `03-restricted.png` | Script 01/04 : namespace PSS restricted et workloads acceptés |
| 04 | `04-inventaire-https.png` | Script 02 : navigateur https://inventaire.local, article ajouté |
| 05 | `05-ingress-tls.png` | Script 02 : Ingress, Certificate Ready, redirection HTTPS |
| 06A | `06a-postgres-avant.png` | Script 03 : article avant suppression Pod |
| 06B | `06b-postgres-apres.png` | Script 03 : article persistant après recréation Pod et PVC Bound |
| 07 | `07-networkpolicy.png` | Script 04 : flux API->Postgres autorisé, intrus bloqué |
| 08 | `08-rbac.png` | Script 04 : `can-i get pods=yes`, `delete pods=no`, `get secrets=no` |
| 09 | `09-hpa-avant-apres.png` | Script 05 : HPA de 2 à >2 réplicas, sortie `kubectl get hpa` |
| 10 | `10-prometheus-alert-firing.png` | Pendant charge : règle InventaireApiLatenceElevee Firing, si déclenchée |
| 11 | `11-grafana-loki.png` | Explore Loki : logs de l'API sous charge + dashboard importé |
| 12A/B | `12-helm-rollback.png` | Script 06 : trois réplicas frontend puis rollback à deux |
| 13 | `13-ci-green.png` | GitHub Actions : build, Trivy CRITICAL, push GHCR, tag auto-commit (uniquement si réussi) |

Les screenshots doivent être copiés manuellement dans `projet/captures/` depuis Windows.
