#!/usr/bin/env python3
"""Ajoute les liens TP4 aux README existants sans écraser les autres TPs."""
from pathlib import Path
root=Path(__file__).resolve().parents[2]
root_readme=root/'README.md'
project_readme=root/'projet'/'README.md'
start='<!-- atlas-tp4-start -->'
end='<!-- atlas-tp4-end -->'
block="<!-- atlas-tp4-start -->\n\n### TP4 — Projet final : Inventaire\n\nL'application trois tiers **Inventaire** (Nginx, Node.js, PostgreSQL) a été déployée en HTTPS à l'aide de Helm sur le cluster Kind. La persistance sur PVC, le RBAC, la collecte Loki et le rollback Helm sont documentés. La montée effective du HPA, la CI et certains tests d'alerting/réseau restent à confirmer.\n\n- [Projet, chart Helm, scripts et workflow](projet/)\n- [Validations terrain et captures](projet/VALIDATIONS_TERRAIN.md)\n- [Archify Atlas : vues TP1 à TP4](https://krokmoo.github.io/k8s-m2/atlas/)\n\n<!-- atlas-tp4-end -->"

assert root_readme.is_file(), 'README racine introuvable'
s=root_readme.read_text()
if start in s and end in s:
    s=s[:s.index(start)]+block+s[s.index(end)+len(end):]
else:
    s=s.rstrip()+'\n\n'+block+'\n'
s=s.replace('Portail Archify Atlas des TPs précédents','Portail Archify Atlas des TPs 1 à 4')
s=s.replace('la vue TP4 et ses preuves seront ajoutées après les validations réelles.', 'les vues TP4 présentent les preuves disponibles et les tests restant à valider.')
root_readme.write_text(s)
assert project_readme.is_file(), 'README projet introuvable'
t=project_readme.read_text()
t=t.replace('> **État** : manifeste de déploiement préparé ; les captures et les résultats de démo doivent être réalisés sur le cluster.', '> **État au 06/11/2026** : déploiement Helm, HTTPS, persistance PostgreSQL, RBAC, logs Loki et rollback observés. HPA > 2 réplicas, alerte TP4, tests NetworkPolicies et CI GitHub Actions restent à valider.')
anchor='[**Voir les validations terrain et les 9 preuves du TP4**](VALIDATIONS_TERRAIN.md).'
if anchor not in t:
    t=t.rstrip()+'\n\n'+anchor+'\n'
project_readme.write_text(t)
print('README.md et projet/README.md mis à jour sans effacer TP1, TP2 ou TP3.')
