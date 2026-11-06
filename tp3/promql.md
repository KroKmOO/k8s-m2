# Requêtes PromQL — TP3

Les expressions suivantes ont été testées graphiquement dans Prometheus, sur le namespace `tp3`. Les métriques HTTP proviennent de `podinfo` et ont été découvertes par `ServiceMonitor`.

## Disponibilité des deux endpoints

```promql
up{namespace="tp3",service="api"}
```

Deux séries à `1` ont été observées.

## CPU par Pod (cœurs)

```promql
sum by(pod) (rate(container_cpu_usage_seconds_total{namespace="tp3",container!=""}[5m]))
```

## Mémoire par Pod (octets)

```promql
sum by(pod) (container_memory_working_set_bytes{namespace="tp3",container!=""})
```

## Trafic (req/s)

```promql
sum(rate(http_request_duration_seconds_count{namespace="tp3"}[5m]))
```

## Latence p95 (s)

```promql
histogram_quantile(0.95, sum by(le) (rate(http_request_duration_seconds_bucket{namespace="tp3"}[5m])))
```

## Taux d'erreurs 5xx (0 à 1)

```promql
sum(rate(http_request_duration_seconds_count{namespace="tp3",status=~"5.."}[5m]))
/
sum(rate(http_request_duration_seconds_count{namespace="tp3"}[5m]))
```

Sans série 5xx, la requête peut retourner un vecteur vide, **pas automatiquement zéro**.

## Taux d'erreurs robustifié pour Grafana (0 à 100 %)

```promql
100 * ((sum(rate(http_request_duration_seconds_count{namespace="tp3",status=~"5.."}[5m])) or vector(0)) / clamp_min(sum(rate(http_request_duration_seconds_count{namespace="tp3"}[5m])), 0.000001))
```

À interpréter seulement avec un trafic total effectivement présent.

## Répartition par status et route

```promql
sum by(status,path) (rate(http_request_duration_seconds_count{namespace="tp3"}[2m]))
```
