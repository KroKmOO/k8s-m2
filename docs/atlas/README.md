# Archify Atlas — Documentation Kubernetes TP1, TP2 & TP3

Documentation graphique et interactive du cluster `m2-k8s`, conçue à partir des énoncés, des manifestes YAML et des captures de tests fournis le 6 novembre 2026.

## Ouvrir le portail

- Sur Windows : ouvrir `docs/atlas/index.html` depuis l’Explorateur.
- En HTTP local (WSL) depuis la racine du dépôt : `python3 -m http.server 8765`, puis ouvrir `http://localhost:8765/docs/atlas/`.
- L’interface est autonome : aucun accès réseau et aucun service Kubernetes requis pour la consulter.

## Ce qui est représenté

1. **TP1 — Cluster Kind** : environnement WSL2/Docker, control-plane, deux workers, Calico, CoreDNS.
2. **TP1 — Données & logs** : StatefulSet MySQL 8.4, Service Headless, PVC 1 Gi, init container, ConfigMap/Secret, Fluent Bit.
3. **TP2 — Ingress TLS** : cert-manager, TLS Secret, routage host/path vers deux Services avec deux réplicas chacun.
4. **TP2 — NetworkPolicies** : deny-all, exceptions DNS/Ingress/frontend/API, accès MySQL inter-namespaces.
5. **TP3 — Observabilité** : métriques Prometheus/podinfo/ServiceMonitor, Grafana Golden Signals, Loki/Fluent Bit, PrometheusRule et Alertmanager.
6. **Tests et preuves** : matrice des sept tests réseau, tests de persistance et galerie des captures de session.

## Sources JSON natives pour Archify

Les six fichiers `sources/*.architecture.json` suivent la structure publique `architecture` d’Archify (JSON IR) : `schema_version`, `diagram_type`, `meta`, `components`, `connections`, `boundaries`, `cards`. Ils sont modifiables et destinés au moteur Archify du dépôt tt-a1i/archify.

**Important — distinction entre portails :** `index.html` est un **portail Atlas autonome créé pour cette remise**, alimenté par les mêmes données ; ce n’est pas un export HTML généré et contrôlé par le moteur Archify. Les JSON n’ont pas été compilés avec le binaire Archify dans cet environnement. Pour obtenir les exports natifs Archify, utiliser le moteur installé chez vous avec les sources ci-dessous et traiter les éventuels diagnostics du validateur.

Depuis le répertoire `archify/` du moteur Archify (Node.js installé), exemple :

```bash
node bin/archify.mjs validate architecture /chemin/vers/docs/atlas/sources/tp1-cluster.architecture.json --quality standard --json
node bin/archify.mjs render architecture /chemin/vers/docs/atlas/sources/tp1-cluster.architecture.json /chemin/vers/tp1-cluster.html
```

Exécuter le même enchaînement pour les six JSON. Avec la distribution Docker que vous utilisez déjà, monter ce dossier sous `/workspace` et remplacer `node bin/archify.mjs` par le point d’entrée `docker compose run --rm archify`, en adaptant les chemins au volume Docker.

## Intégrer dans le dépôt `k8s-m2`

Copier **le dossier `docs/`** à la racine de `~/k8s-m2/` :

```bash
cd ~/k8s-m2
git add docs/atlas/
git commit -m "Documentation Atlas : architecture et preuves TP1 TP2 TP3"
git push
```

Le portail ne remplace pas les fichiers `tp1/`, `tp2/` et `tp3/` exigés par la formatrice. Conserver également leurs README et les sorties de tests d’origine.

## Limites et provenance

- État documenté au **6 novembre 2026**, sans inspection live récente du cluster ou de GitHub.
- Les captures proviennent des preuves envoyées dans la conversation ; elles ne doivent pas être interprétées comme une supervision en temps réel.
- Les tests CLI démontrent des comportements observés sur cet environnement de laboratoire, sans garantir un durcissement de production.
- Aucun mot de passe, Secret Kubernetes ou kubeconfig n’est inclus.

**Référence du moteur :** https://github.com/tt-a1i/archify

## Extension TP3

- `sources/tp3-metrics.architecture.json` : flux de métriques et dashboard.
- `sources/tp3-logs-alerting.architecture.json` : collecte des logs, stockage et alerting.
- `assets/preuves/tp3/` : seize captures provenant de la séance du 6 novembre 2026.
- [Compte rendu et 11 réponses](../../tp3/README.md).

La présentation Atlas est **statique** (GitHub Pages) et ne prend pas la main sur Grafana, Prometheus ou Kind.


## TP4 — Inventaire (06/11/2026)

Deux nouvelles vues Archify Atlas documentent l’application trois tiers, sa persistance PostgreSQL et les contrôles de sécurité et d’observabilité. Les 9 captures utilisées sont classées dans `assets/preuves/tp4/`, portant la galerie à 49 preuves.

Les vues distinguent les validations confirmées (Helm, HTTPS, PVC, RBAC, Loki, rollback) et les tests restant à démontrer (HPA scale-up, NetworkPolicies, alerte TP4 FIRING et GitHub Actions).

Sources éditables : `sources/tp4-inventaire.architecture.json` et `sources/tp4-securite-hpa.architecture.json`. Le portail HTML est statique et documentaire.
