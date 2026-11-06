# Installer la mise à jour Archify Atlas TP4

Extraire l'archive **à la racine du dépôt** `~/k8s-m2`.

```bash
cd ~/k8s-m2
unzip -o "/chemin/Correctif_Archify_Atlas_TP4_et_preuves.zip" -d .
python3 projet/scripts/09-maj-readmes-tp4.py
python3 -m json.tool docs/atlas/atlas-data.json >/dev/null
python3 -m http.server 8765
```

Tester `http://localhost:8765/docs/atlas/`, puis publier via Git. Ne pas confondre le commit GitHub (code) et le déploiement Pages (portail).

### Périmètre

- 8 vues interactives, dont TP4 Inventaire et TP4 Sécurité/HPA.
- 49 preuves au total (9 TP4).
- État détaillé documenté dans `projet/VALIDATIONS_TERRAIN.md`.
- Aucune connexion live ; Archify JSON non compilé par le moteur natif.
- L'HPA n'a pas été observé au-delà de deux replicas et la CI n'est pas validée par les captures.
