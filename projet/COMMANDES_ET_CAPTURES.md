# TP4 — commandes intégrales et moments de capture

**Lancer les scripts dans cet ordre, depuis Ubuntu WSL :**

```bash
cd ~/k8s-m2/projet
bash scripts/00-preflight.sh       # SCREEN 01
bash scripts/01-deployer.sh        # SCREENS 02, 03
bash scripts/02-tester-https.sh    # SCREENS 04, 05
bash scripts/03-persistance.sh     # SCREENS 06A et 06B (pause avant suppression)
bash scripts/04-securite-reseau.sh # SCREENS 07 et 08
bash scripts/05-charge-hpa.sh      # SCREENS 09, 10, 11 pendant charge
bash scripts/06-rollback.sh       # SCREEN 12
bash scripts/07-etat-final.sh     # Récapitulatif
```

## Ouvertures navigateur

- `https://inventaire.local` : nécessite entrée dans hosts Windows (`127.0.0.1 inventaire.local`), accepte le certificat auto-signé pour le labo.
- Grafana : `http://localhost:3001` si le port-forward est toujours actif ; importer `projet/grafana/golden-signals-inventaire.json`.
- Prometheus : `http://localhost:9090/targets` et `/alerts`.
- Alertmanager : `http://localhost:9093`.

Si besoin (un terminal WSL par port-forward) :

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3001:80
kubectl -n monitoring port-forward svc/prometheus-operated 9090:9090
kubectl -n monitoring port-forward svc/alertmanager-operated 9093:9093
```

## PromQL / LogQL utiles

```promql
up{namespace="inventaire",service="inventaire-api"}
```

```promql
histogram_quantile(0.95,sum by(le)(rate(http_request_duration_seconds_bucket{namespace="inventaire",service="inventaire-api"}[2m])))
```

```logql
{namespace="inventaire"} |= "/api/cpu"
```

Ne pas commencer `scripts/05-charge-hpa.sh` avant d'avoir confirmé que `kubectl top nodes` fonctionne. La PrometheusRule peut ne passer en Firing que si la charge franchit et maintient le seuil.

## Push final (après les tests)

```bash
cd ~/k8s-m2
git status
git add README.md projet/ .github/workflows/ci.yaml
git diff --cached --check
git commit -m "TP4 Inventaire Helm securite observabilite HPA et CI"
git fetch origin
git pull --rebase origin main
git push -u origin main
```

Le workflow `ci.yaml` est dans `.github/workflows/ci.yaml` à la racine. **La CI ne se termine pas obligatoirement en vert** : un scan CRITICAL détecté bloque volontairement la publication. Ne jamais désactiver Trivy pour gagner des points.
