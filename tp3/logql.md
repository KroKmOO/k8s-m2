# Requêtes LogQL — TP3

Les recherches ont été réalisées via Grafana **Explore → Loki**. Le jeu de labels provient de Fluent Bit et des métadonnées Kubernetes.

| Objectif | Requête |
|---|---|
| Logs du namespace | `{namespace="tp3"}` |
| Journaux API | `{namespace="tp3",app="api"}` |
| Journaux du générateur d'erreurs | `{namespace="tp3",app="chaos"}` |
| Événements ERROR | `{namespace="tp3"} |= "ERROR"` |
| ERROR ou WARN | `{namespace="tp3"} |~ "ERROR|WARN"` |
| Exclure INFO | `{namespace="tp3",app="chaos"} != "INFO"` |
| ERROR par minute et par app | `sum by(app)(count_over_time({namespace="tp3"} |= "ERROR" [1m]))` |
| API structurée (JSON) | `{namespace="tp3",app="api"} | json` |

## Preuves

- Message `TP3_LOKI_TEST` produit par un Pod éphémère, retrouvé dans Loki.
- Messages `ERROR appel /status/500 en echec` retrouvés pour `app=chaos`.
- Le navigateur de logs affichait notamment `job=fluent-bit`, `namespace`, `app` et `container`.

La présence de `ERROR` côté client, seule, ne prouve pas un HTTP 500. Le compteur Prometheus `status="500"` et le dashboard à **72,34 %** ont permis de confirmer la génération réelle d'erreurs serveur.
