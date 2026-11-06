# Livraison TP3 — commandes GitHub et Atlas

## Avant de commencer

Le ZIP fourni est une **mise à jour ciblée du dépôt**. Il contient `README.md`, `tp3/` et certains fichiers de `docs/atlas/` seulement. Il **n'efface pas** les dossiers `tp1/`, `tp2/` ni les anciennes preuves. Vérifier les changements avec `git diff` avant le commit. Les fichiers `docs/atlas/index.html` et `docs/atlas/atlas-data.json` sont fondés sur l'Atlas TP1+TP2 précédemment fourni ; si tu l'as fortement personnalisé entretemps, sauvegarde-les avant d'extraire le ZIP et réconcilie les modifications.

## Copier le ZIP depuis Téléchargements Windows

Si tu as placé le fichier dans le dossier Téléchargements Windows :

```bash
wsl -d Ubuntu                      # depuis PowerShell seulement
cd ~/k8s-m2
# Facultatif, pour sécuriser la version courante
cp README.md /tmp/k8s-m2-README-sauvegarde.md
cp docs/atlas/index.html /tmp/k8s-m2-atlas-sauvegarde.html
# Le chemin Windows peut varier selon ton dossier Téléchargements
unzip -o "/mnt/c/Users/Dylan Cailleau/Downloads/k8s-m2-TP3-Atlas-GitHub.zip" -d .
```

## Vérifier et publier

```bash
cd ~/k8s-m2
python3 -m json.tool tp3/golden-signals.json >/dev/null
python3 -m json.tool docs/atlas/atlas-data.json >/dev/null
python3 -m json.tool docs/atlas/sources/tp3-metrics.architecture.json >/dev/null
python3 -m json.tool docs/atlas/sources/tp3-logs-alerting.architecture.json >/dev/null

git status
git diff --stat
git diff -- README.md docs/atlas/index.html

git add README.md tp3/ docs/atlas/
git commit -m "TP3 observabilite : compte rendu, preuves, Grafana et Atlas"
git fetch origin
git pull --rebase origin main
git push -u origin main

git status
```

## Tester le portail Atlas

```bash
cd ~/k8s-m2
python3 -m http.server 8765
```

Navigateur Windows : `http://localhost:8765/docs/atlas/`. Pour arrêter : **Ctrl+C**.

Après le `git push` et le déploiement GitHub Pages : `https://krokmoo.github.io/k8s-m2/atlas/`. L’Atlas est statique et ne nécessite pas la présence du cluster.

## Export Grafana

Le fichier `tp3/golden-signals.json` est un **export classique portable**, avec deux sources à sélectionner lors de l’import : `Prometheus` et `Loki`. Le fichier `tp3/golden-signals-grafana13-export.json` est une version nettoyée de ton export Grafana 13 Dashboard v2, destinée à l'archivage de la configuration réellement construite ; un panneau vide y a été supprimé et les logs replacés sous les erreurs.

## Validation native Archify (facultative)

Les fichiers `docs/atlas/sources/tp3-*.architecture.json` suivent la structure IR conservée dans ce dépôt. Ils ne sont pas des rendus produits par le moteur Archify : le portail HTML autonome les affiche. La validation native reste à effectuer dans ton installation Archify/Docker si elle est exigée.
