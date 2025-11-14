# VPS et déploiement docker-compose

Ce projet a pour but de faciliter le déploiement d'un nouveau VPS ainsi qu'un Saas SPA/API au plus vite en générant un package de déploiement.

Pour les plus curieux/impatients qui souhaitent voir plutôt que lire, vous pouvez directement lancer l'image docker dans le répertoire de votre choix : "**docker run davidozvald/vps-saas-deployer**"

Il contient (en l'état, mais il peut être évidemment adapté à vos besoins) l'outillage nécessaire pour le déploiement des projets **SPA Angular**, **API .NET Core** ainsi que la base **MySQL** et enfin le **reverse proxy**.  
Ce déploiement docker peut aussi bien être utilisé sur un poste de développeur que sur le VPS ou n'importe quelle machine hôte. Il fournit une configuration et une stack homogène et cohérente entre **développement (local)**, **staging (VPS)** et **production (VPS)**.

**Pour un poste de développeur** : il permet de builder l'image docker localement, et de lancer la stack docker-compose.
**Pour un VPS (ou autre serveur de déploiement)** : il permet de déployer en quelques secondes votre Saas Spa/Api avec simplicité.

Quelques prérequis diffèreront selon le cas d'usage de ce package, entre poste de développeur et environnement de déploiement (staging, production).

Ce package contiendra également (**TO DO**) des outillages permettant de configurer le VPS.

## Projet Git et customisation

Ce projet Git est public, et fournit une structure "par défaut" (.NET / Angular / reverse proxy) pour le build et le déploiement de vos images.
Vous êtes libres de cloner ce projet et de l'adapter à vos besoins. Vous pourrez ensuite générer votre propre image Docker, grâce au dockerfile déjà présent, et l'utiliser à votre convenance.

Vous pouvez aussi utiliser directement l'image docker que je mets à disposition publiquement : "**docker run davidozvald/vps-saas-deployer**". Cette image docker génèrera le package de build/déploiement directement dans le dossier courant, qui nécessitera une rapide configuration (voir sections suivantes).

## Configuration des projets Git

**Prérequis**: Les projets Git de vos projets doivent être nommés sous la forme **MonProjet_spa** et **MonProjet_api**.

**Prérequis**: De plus, si vous souhaitez utiliser ce package sur un poste de développeur, ces 2 projets devront se trouver dans un **dossier commun**.

Une autre organisation des dossiers et projets est possible, nécessitera d'adapter les fichiers docker-compose.yml en conséquence.

## Récupération du package de déploiement via docker

Pour récupérer ce package de déploiement sur le VPS (staging et production) ou le poste de développement (dev), 2 possibilités :
- via **docker run en une seule commande** (solution **à privilégier**, voir suite de ce paragraphe)
- via un git clone du projet (nécessitera la suppression de certains fichiers et dossiers: .gitignore, .git, .dockerignore etc...).

**Prérequis**: Si vous souhaitez utiliser ce package sur un **poste de développeur**, il est **nécessaire** que le dépôt soit récupéré dans le même **dossier parent qui contient déjà vos 2 projets Git Spa et Api** (voir paragraphe précédent).
En effet, celui-ci nécessite d'accéder aux dockerfile des 2 projets (par chemin relatif) pour effectuer le "build" dans le docker-compose.dev.yml.

Concernant les environnements staging et production, il ne semble pas y avoir de contrainte d'emplacement particulière pour le package.

Les commandes suivantes indiquent comment déployer le package dans le répertoire courant :
- **Git Bash (Windows)**: docker run --pull always --rm -v "$(pwd -W):/target" davidozvald/vps-saas-deployer:latest
- **PowerShell (Windows)**: docker run --pull always --rm -v "${pwd}:/target" davidozvald/vps-saas-deployer:latest
- **Linux/macOS**: docker run --pull always --rm -v .:/target -e HOST_UID=\$(id -u) -e HOST_GID=\$(id -g) davidozvald/vps-saas-deployer:latest

## Configuration du dépôt 

Le package doit maintenant être configuré pour votre Saas, par l'intermédiaire du fichier **.env** dans le dossier **/docker** 

Veuillez modifier également les **server_name** des fichiers de configuration du reverse_proxy dans **/docker/reverse-proxy-conf** pour qu'ils correspondent à votre nom de domaine (ou IP de VPS).
Les fichiers concernés sont ceux de "staging" et de "production", celui de "dev" n'écoutant que sur localhost.

---

## ⚙️ Environnement et Docker Compose

**La stack docker utilise 4 conteneurs** : SPA, API, MySQL, et reverse proxy (nginx).
Le reverse proxy effectue la distribution des appels entre frontend et backend, et est également responsable des certificats TLS en usage "production".

### 📜️ makefile

Le fichier `makefile` contient les commandes nécessaires pour utiliser les fonctionnalités de docker compose.
Il permet de gérer les déploiements des 3 environnements: dev, staging et production.

Pour voir les commandes make disponible : "**make help**"

Il fournit des alias très simples pour démarrer et arrêter les stacks docker-compose.
Vous êtes libre de modifier ce fichier makefile afin d'ajouter les commandes supplémentaires dont vous auriez besoin.

---

### 🔧 Développement local
Utilise `docker-compose.dev.yml` avec une stack identique à la production.

Ce fichier et ses commandes associés (makefile) ne seront utiles que pour un usage sur un poste de développeur.

Ports d'accès une fois la stack lancée:
- **80**   : usage normal (accès par reverse_proxy)
- **81**   : accès direct au container frontend (SPA). Utilisable en décommentant la ligne correspondante dans docker-compose.dev.yml, pour debug uniquement.
- **5000** : accès direct au container backend (API). Même remarque que ci-dessus.

---

### 🧪 Staging (préproduction)
Utilise `docker-compose.staging.yml` avec une stack identique à la production.

Ports d'accès une fois la stack lancée:
- **82** : usage normal (accès par reverse_proxy)

---

### 🚀 Production
Utilise `docker-compose.production.yml`.  
Reverse proxy avec HTTPS et certificats TLS.
Les certificats TLS sont récupérés depuis /etc/ssl. Voir le fichier docker-compose.prod.yml.

Ports d'accès une fois la stack lancée:
- **80** : redirection vers Https sur le port 443)
- **443**: usage normal (Https, accès par reverse_proxy)

---

## 📜 Logs

Les logs du Saas sont rémontés (via un volume) dans le dossier "logs" à la racine du dépôt.
Les logs sont séparés par environnement (dev, staging, production) et par container (api, spa, reverse_proxy).

---

## 🛢️ Base de données

Les fichiers docker-compose utilisent chacun un volume pour la base de données.
Le volume utilisé pointe vers le dossier : **/docker/database-volumes**, dont le contenu est séparé par environnement (dev, staging ,production).

---

## 🖥️ VPS

**TO DO.**
Ce dossier fournira les scripts utiles pour configurer au plus vite un nouveau VPS (redéfinition du port SSH, passwords, fail2ban, chmod, letsencrypt...).

---

## 🧹 Commandes utiles supplémentaires

- Lister les containers actifs (pour vérifier le bon lancement de la stack docker compose notamment)
  docker ps

- Accéder au shell d'un container :
  docker exec -it <nom_container> sh
  
- Accéder au shell MySQL du conteneur "database":  
  docker exec -it <nom_container_mysql> mysql -u<user> -p<password>
