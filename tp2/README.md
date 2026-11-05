# TP2 — Ingress, TLS et Network Policies

**Cours :** Kubernetes M2 Super Cloud  
**Date des expérimentations :** 5 novembre 2026  
**Environnement :** Windows 11 / WSL2 Ubuntu / Docker Desktop / Kind `m2-k8s` (Kubernetes v1.37.0) / Calico  
**Groupe :** à compléter avant dépôt GitHub  
**Statut :** tests des étapes 1 à 8 effectués ; exercice inter-namespaces vérifié. Preuve TLS détaillée à récupérer localement (`tls-test.txt`).

## 1. Objectifs et déploiement

Ce TP met en place une application deux tiers (frontend Nginx et API HTTP), publiée derrière un contrôleur ingress-nginx. Les domaines locaux `www.tp.local` et `api.tp.local` aboutissent au même contrôleur, qui route les requêtes par hôte ou par chemin. cert-manager crée un certificat auto-signé pour le HTTPS. Enfin, Calico applique une segmentation de type deny-all avec des exceptions explicites.

| Élément | Configuration |
|---|---|
| Cluster | `m2-k8s`, 1 control-plane + 2 workers |
| Réseau | Calico, moteur de NetworkPolicies |
| Contrôleur | ingress-nginx, nodeSelector `ingress-ready=true`, ports hôte 80/443 |
| Namespace applicatif | `tp2` |
| API | `hashicorp/http-echo:1.0`, 2 réplicas, port 8080 |
| Frontend | `nginx:1.27-alpine`, 2 réplicas, port 80 |
| Ingress | `www.tp.local/` → frontend ; `www.tp.local/api` et `api.tp.local/` → API |
| HTTPS | cert-manager, ClusterIssuer `selfsigned`, secret `tp2-tls` |
| Sécurité | deny-all + DNS + Ingress + frontend/API + API/MySQL |

> L'utilisation de l'ancien contrôleur ingress-nginx et de certificats auto-signés est limitée à cet exercice local : ce n'est pas une configuration de production. Avec le certificat auto-signé, la vérification TLS par le navigateur ou `curl` échoue sans confiance préalable ; `curl -k` est réservé à ce laboratoire.

## 2. Déroulement des expérimentations

1. Installation de `ingress-nginx` via Helm avec `values-ingress.yaml`. Le contrôleur est `1/1 Running` ; `curl -i http://localhost` répond `HTTP/1.1 404 Not Found`, attestant de sa disponibilité avant toute règle Ingress. Voir `captures/01-ingress-nginx-404.png`.
2. Déploiement de `apps.yaml`. Le DNS `api.tp2.svc.cluster.local` résout le Service `10.96.106.252` ; BusyBox récupère `Bonjour depuis l'API` et la page HTML du frontend. Les deux endpoints API observés sont `192.168.231.151:8080` et `192.168.240.76:8080`. Voir `captures/02-*` et `03-*`.
3. Configuration `ingress.yaml` et fichier hosts Windows. Les pages `http://www.tp.local`, `http://api.tp.local` et `http://www.tp.local/api` répondent conformément aux routes. Voir `captures/04-*`, `05-*` et `06-*`.
4. Déploiement de cert-manager et `ClusterIssuer/selfsigned`. `Certificate/tp2-tls` est `Ready=True` ; `Secret/tp2-tls` de type `kubernetes.io/tls` existe. `curl -I http://www.tp.local` retourne `308 Permanent Redirect` vers HTTPS et `curl -k https://www.tp.local` affiche la page HTML. Voir `captures/07-*`.
5. Avant la politique, un Pod du namespace `default` peut atteindre le Service API : la communication réseau est autorisée par défaut.
6. Application `np-01-deny-all.yaml`. `curl -k -m 5 https://www.tp.local` ne reçoit aucune réponse avant timeout ; `wget http://api:8080` depuis le frontend échoue dès la résolution DNS (`bad address`). Voir `captures/08-*`.
7. Application des politiques DNS, contrôleur Ingress et frontend/API. Le trafic autorisé est rétabli ; l'intrus extérieur reste bloqué. Voir `captures/09-*`.
8. Tests complémentaires (Pod intrus dans `tp2`, frontend vers Internet, API vers frontend via conteneur éphémère) : les trois flux échouent par timeout. Voir `captures/10-*`.
9. Exercice supplémentaire : `np-05-api-to-mysql.yaml` autorise la sortie de l'API de `tp2` vers MySQL de `tp1` sur TCP/3306 ; `np-06-mysql-ingress.yaml` limite les entrées MySQL aux applications API des namespaces `tp1` et `tp2`. Les politiques existent dans les deux namespaces ; `nc` depuis l'API de `tp1` réussit, le Pod intrus de `tp1` échoue, et le diagnostic récupéré depuis le conteneur éphémère de l'API de `tp2` confirme : DNS → `192.168.231.147`, **`Code retour TCP : 0`**. Voir `captures/11-*`, `12-*` ; le dernier diagnostic a été transmis en sortie texte dans la conversation et non en capture.

## 3. Matrice des 7 tests réseau

| N° | Flux | Attendu | Observé | Preuve |
|---|---|---|---|---|
| 1 | Client extérieur → frontend HTTPS | Autorisé | Réponse HTML `Frontend M2 Super Cloud` | `captures/09-autorisation-selective.png` |
| 2 | Client extérieur → API HTTPS | Autorisé | `Bonjour depuis l'API` | `captures/09-autorisation-selective.png` |
| 3 | Frontend → API TCP/8080 | Autorisé | `Bonjour depuis l'API` | `captures/09-autorisation-selective.png` |
| 4 | Intrus namespace `default` → API | Bloqué | `wget: download timed out` | `captures/09-autorisation-selective.png` |
| 5 | Intrus namespace `tp2` → API | Bloqué | `wget: download timed out` | `captures/10-tests-negatifs-complementaires.png` |
| 6 | Frontend → `example.com` en HTTP | Bloqué | `wget: download timed out` | `captures/10-tests-negatifs-complementaires.png` |
| 7 | API → frontend HTTP | Bloqué | `wget: download timed out` (conteneur éphémère BusyBox) | `captures/10-tests-negatifs-complementaires.png` |

Le test 7 a été réalisé depuis l'espace réseau du Pod API au moyen de `kubectl debug`, car l'image `hashicorp/http-echo` ne fournit ni shell ni `wget`. Les politiques permettent ainsi de vérifier séparément les communications autorisées et les communications interdites.

## 4. Réponses aux huit questions de la formatrice

### Question 1 — Pourquoi placer le contrôleur sur le control-plane ? Et sur un cluster cloud ?

Dans la configuration Kind utilisée pour ce cours, le nœud control-plane est le seul dont les ports de conteneur 80 et 443 sont mappés sur ceux de la machine hôte, et il porte le label `ingress-ready=true`. Le nodeSelector force donc le contrôleur sur ce nœud afin qu'il reçoive les connexions externes. Sur un cluster cloud, un Service de type `LoadBalancer` et le load balancer du fournisseur peuvent assurer l'exposition du contrôleur ; celui-ci n'a plus besoin d'être placé sur le control-plane et peut être répliqué sur des workers.

### Question 2 — Combien d'IP derrière le Service `api` ?

**Deux endpoints** : `192.168.231.151:8080` (Pod `api-854dc5dbdb-mw2lm`, worker 1) et `192.168.240.76:8080` (Pod `api-854dc5dbdb-t8sx5`, worker 2). Le Service possède une IP virtuelle stable `10.96.106.252`, tandis que chaque endpoint correspond à un Pod API disponible. La ressource classique `Endpoints` est dépréciée au profit d'`EndpointSlice` dans cette version de Kubernetes, sans changer le principe.

### Question 3 — Quel objet cert-manager est automatiquement créé ?

L'annotation `cert-manager.io/cluster-issuer: selfsigned` sur l'Ingress permet au mécanisme ingress-shim de créer un objet **Certificate** pour les hôtes déclarés dans `spec.tls`. Le certificat émis est stocké dans le Secret `tp2-tls`. L'observation confirme `Certificate/tp2-tls: Ready=True` et `Secret/tp2-tls: kubernetes.io/tls`.

### Question 4 — Pourquoi `curl -k` ? Que changerait Let's Encrypt ?

Un certificat auto-signé ne peut pas être validé à l'aide d'une chaîne de confiance reconnue par défaut par le poste client. Le paramètre `-k` ignore la validation du certificat pendant le TP, mais cette option n'est pas acceptable en production. Avec un domaine réel et une validation de domaine adaptée (HTTP-01 ou DNS-01), un ClusterIssuer Let's Encrypt produirait un certificat généralement reconnu par les navigateurs ; `curl` pourrait vérifier la chaîne sans `-k`.

### Question 5 — Pourquoi la résolution DNS échoue-t-elle après deny-all ?

Une NetworkPolicy `default-deny-all` contenant `policyTypes: [Ingress, Egress]`, sans règle d'autorisation, interdit toutes les nouvelles connexions de sortie depuis les Pods du namespace `tp2`. Les requêtes DNS à CoreDNS (UDP/TCP port 53) sont donc bloquées ; depuis le frontend, `wget` échoue sur `api:8080` avec `bad address`. L'exception `allow-dns-egress` rétablit uniquement les requêtes vers les Pods CoreDNS.

### Question 6 — Si on supprime `np-02-allow-dns.yaml`, quels tests échouent ?

Le test 3 (frontend → API par nom DNS) échouerait, puisque le frontend ne pourrait plus résoudre `api`. Les tests 5, 6 et 7 sont déjà censés être refusés : ils continueraient à échouer, parfois plus tôt lors de la résolution DNS. Les tests 1 et 2, réalisés depuis la machine hôte par HTTPS via l'Ingress, ne dépendent pas de la sortie DNS des Pods `tp2` et resteraient normalement fonctionnels. Réponse théorique : cette suppression n'a pas été effectuée sur le cluster conservé pour les TP suivants.

### Question 7 — Une NetworkPolicy est-elle un deny ou un allow ? Cumuls ?

Une NetworkPolicy standard est fondamentalement une **liste d'autorisations**. Un Pod non sélectionné pour une direction reste ouvert dans cette direction ; lorsqu'au moins une politique le sélectionne pour `Ingress` ou `Egress`, seuls les flux explicitement permis par l'ensemble des politiques applicables sont autorisés. Les règles des différentes politiques sont **additives** : une politique ne retire pas une permission accordée par une autre. Une communication entre Pods doit être permise à la fois en sortie côté source et en entrée côté destination, lorsqu'ils sont isolés dans ces directions.

### Question 8 — Même YAML avec le CNI par défaut kindnet ? Comment vérifier ?

Les objets `NetworkPolicy` seraient acceptés par l'API Kubernetes, mais le CNI Kind par défaut (`kindnet`) ne met pas en œuvre l'application des règles. Les flux censés être bloqués pourraient alors continuer à fonctionner. Pour le prouver, il faudrait créer un **cluster de test séparé** avec le CNI Kind par défaut, appliquer les mêmes workloads et politiques, puis rejouer les tests 4 à 7 et comparer les résultats. Il ne faut pas détruire `m2-k8s`, qui sert aux TP suivants. Réponse explicative, non testée ici sur un second cluster.

## 5. Complément — Segmentation MySQL inter-namespaces

Le sujet demande : « l'API doit maintenant pouvoir joindre MySQL du TP1 (`mysql-0.mysql.tp1`, port 3306), et rien d'autre ». Nous avons créé :

- `np-05-api-to-mysql.yaml` dans `tp2` : `app=api` → namespace `tp1` + `app=mysql`, TCP 3306, en Egress.
- `np-06-mysql-ingress.yaml` dans `tp1` : vers `app=mysql`, TCP 3306, uniquement depuis `app=api` de `tp1` ou depuis `app=api` du namespace `tp2`.

**Résultats réellement observés :** connexion API TP1 → MySQL OK ; le Pod non autorisé `mysql-intrus` de `tp1` se termine en erreur ; résolution DNS MySQL depuis le conteneur de débogage API TP2 vers `192.168.231.147` et `Code retour TCP : 0`. Le test TCP prouve l'ouverture du port, pas une authentification SQL.

> Les politiques sont adaptées au périmètre du TP. La règle autorisant le contrôleur Ingress sélectionne le namespace entier et ne limite pas les ports ; en production, elle serait resserrée sur les labels du contrôleur et sur les seuls ports 80/8080.

## 6. Preuves et livrables

Les captures fournies se trouvent dans `captures/`. Tous les manifestes demandés sont présents : `values-ingress.yaml`, `apps.yaml`, `ingress.yaml`, `issuer.yaml`, `np-01` à `np-06`.

**Fichier à ajouter depuis l'environnement réel :** `tls-test.txt` (sortie brute de `curl -kv https://www.tp.local` montrant la négociation TLS). Ce fichier a été généré sur le poste WSL par l'étudiant, mais son contenu n'a pas été transmis ; il n'est pas reconstitué artificiellement dans ce livrable. Copier le fichier depuis `~/k8s-m2/tp2/tls-test.txt` avant le dépôt GitHub. Si nécessaire, le recréer :

```bash
cd ~/k8s-m2/tp2
curl -kv https://www.tp.local > tls-test.txt 2>&1
```

Le contrôleur Ingress, le cluster Kind et les namespaces sont conservés pour le TP3.

## 7. Reproduction et vérification

Depuis la racine du dépôt `k8s-m2` (cluster `m2-k8s` préparé par le TP1) :

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  -n ingress-nginx --create-namespace -f tp2/values-ingress.yaml

kubectl apply -f tp2/apps.yaml
helm upgrade --install cert-manager jetstack/cert-manager \
  -n cert-manager --create-namespace --set crds.enabled=true
kubectl apply -f tp2/issuer.yaml
kubectl apply -f tp2/ingress.yaml
kubectl apply -f tp2/np-01-deny-all.yaml \
  -f tp2/np-02-allow-dns.yaml \
  -f tp2/np-03-allow-ingress-controller.yaml \
  -f tp2/np-04-frontend-to-api.yaml \
  -f tp2/np-05-api-to-mysql.yaml \
  -f tp2/np-06-mysql-ingress.yaml
```

Pré-requis : les dépôts Helm doivent être accessibles, la `StorageClass`/CNI du TP1 sont en place, et les hôtes `www.tp.local` et `api.tp.local` pointent vers `127.0.0.1` sur la machine Windows. Les noms `.local` ne sont pas destinés à un DNS Internet public.
