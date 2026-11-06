# Notes techniques et de traçabilité

## Périmètre

Cet atlas documente les **TP1, TP2 et TP3** du programme M2 Super Cloud. Les vues TP3 couvrent Prometheus, Grafana, Loki, Fluent Bit et Alertmanager. Le TP4 ne fait pas encore partie du périmètre documenté. Toutes les vues sont des reconstructions de laboratoire, sans liaison directe aux clusters Kubernetes.

## Résultats observés

- Cluster 3 nœuds Ready, Calico, CoreDNS.
- Nginx `hello` : répond localement via port-forward, pas de recréation après suppression.
- Deployment `web` : passage 3→5 réplicas, erreur volontaire nginx:9.99-inexistante, 4 disponibles, retour 5/5.
- MySQL : données Awa/Lucas/Ines après recréation du Pod et du StatefulSet, PVC Bound.
- Fluent Bit : sorties JSON de logs via shared emptyDir ; injection DB_HOST / DB_PASSWORD confirmée sans exposer le mot de passe.
- Ingress : frontend www.tp.local, API api.tp.local et chemin www.tp.local/api.
- TLS : cert-manager, certificat auto-signé Ready, code HTTP 308, HTTPS accessible via curl -k.
- NetworkPolicy : deny-all puis réouverture sélective, 7/7 scénarios réseau observés.
- MySQL inter-namespaces : API TP1 et API TP2 atteignent TCP 3306, intrus TP1 échoue ; DNS API TP2 résolu vers 192.168.231.147.

## Attention

- Le DNS/IP de MySQL a été relevé à un instant, et peut évoluer après recréation de Pods ; l’identité DNS est la référence stable.
- Le contrôle d’accès fait par NetworkPolicies n'est pas une authentification MySQL.
- Le sélecteur de la politique `allow-from-ingress-controller` autorise les Pods du namespace concerné sans limitation par port dans le manifeste de cours ; ne pas promettre une restriction à 80/8080 en entrée, même si ce sont les seuls ports de service utilisés.
- La ConfigMap DB_HOST est modifiée dans l’environnement ; les manifests du rendu incluent l'état de cours documenté.

## Emplacements sources dans le dépôt parent

- TP1 : `tp1/kind-config.yaml`, `mysql.yaml`, `mysql-config.yaml`, `api-sidecar.yaml`, `README.md`.
- TP2 : `tp2/values-ingress.yaml`, `apps.yaml`, `ingress.yaml`, `issuer.yaml`, `np-01` à `np-06`, `README.md`.
- TP3 : `tp3/api-tp3.yaml`, `servicemonitor.yaml`, `values-monitoring.yaml`, `values-loki.yaml`, `values-fluent-bit.yaml`, `alert-rules.yaml`, `chaos.yaml`, `golden-signals.json`, `README.md`.
- Résultats : `tp1/etat-final.txt`, `tp2/tls-test.txt`, `tp3/preuves/`, captures reprises sous `assets/preuves/`.

## Addendum TP3 — 6 novembre 2026

Les vues TP3 ont été ajoutées à partir des sorties et captures fournies dans la conversation. Les mesures reportées (1,86 → 7,17 req/s, 72,34 % HTTP 5xx, API 2/2 UP, alerte FIRING reçue par Alertmanager) sont ponctuelles et vérifiables par les fichiers `tp3/preuves/`. Les sources IR de TP3 sont destinées à Archify et non validées par exécution native du moteur dans cette session. La génération du portail HTML est autonome, sans lien en direct avec un cluster.
