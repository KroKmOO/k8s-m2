# Archify Atlas — TP1 et TP2 Kubernetes

## Installation sous Ubuntu WSL2

Depuis la racine du dépôt GitHub `k8s-m2`, décompressez cette archive **sans écraser les fichiers YAML ni README des TP existants** :

```bash
cd ~/k8s-m2
unzip -n "/mnt/c/Users/UTILISATEUR_WINDOWS/Downloads/Archify_Atlas_Kubernetes_TP1_TP2.zip" -d .
```

Ouvrir ensuite `docs/atlas/index.html` dans Windows ou lancer :

```bash
cd ~/k8s-m2
python3 -m http.server 8765
```

Puis ouvrir `http://localhost:8765/docs/atlas/`.

Publier seulement après avoir vérifié les fichiers :

```bash
git add docs/ INSTALLATION.md
git commit -m "Ajout documentation Atlas TP1 TP2"
git push
```

## Publication web facultative pour la formatrice

Sur GitHub : **Settings → Pages → Deploy from a branch → main → /docs**. Après activation et publication par GitHub, le portail devrait être disponible sur le sous-chemin `/atlas/` de votre site GitHub Pages. La configuration Pages n'est pas effectuée automatiquement par cette archive.

## Ce qui est inclus

- `docs/atlas/index.html` : atlas interactif autonome ;
- `docs/atlas/sources/` : 4 architectures en JSON IR destinées à Archify ;
- `docs/atlas/assets/preuves/` : 24 captures de séance ;
- `docs/atlas/README.md` et `PROVENANCE.md` : fonctionnement, limites et traçabilité.

Les pages natives générées par le moteur Archify ne sont pas incluses : le moteur Archify n'était pas disponible à l'exécution ici ; les sources JSON sont prêtes pour validation/rendu sur votre installation existante.
