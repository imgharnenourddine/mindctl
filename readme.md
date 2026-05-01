<div align="center">

```
███╗   ███╗██╗███╗   ██╗██████╗  ██████╗████████╗██╗
████╗ ████║██║████╗  ██║██╔══██╗██╔════╝╚══██╔══╝██║
██╔████╔██║██║██╔██╗ ██║██║  ██║██║        ██║   ██║
██║╚██╔╝██║██║██║╚██╗██║██║  ██║██║        ██║   ██║
██║ ╚═╝ ██║██║██║ ╚████║██████╔╝╚██████╗   ██║   ███████╗
╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝   ╚═╝   ╚══════╝
```

**Orchestrateur Intelligent de Données et d'Environnement DevOps sous Linux**

[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![C](https://img.shields.io/badge/C-99-A8B9CC?style=for-the-badge&logo=c&logoColor=white)](https://en.wikipedia.org/wiki/C99)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![LLM](https://img.shields.io/badge/LLM-Mistral%20AI%20API-7C3AED?style=for-the-badge)](https://mistral.ai/)
[![ENSET](https://img.shields.io/badge/ENSET-Mohammedia%202026-0EA5E9?style=for-the-badge)](.)

<br/>

> 🤖 **mindctl** est un outil en ligne de commande Bash/C qui corrige automatiquement les conflits de configuration DevOps, vérifie la compatibilité du système Linux, lance le projet, et analyse intelligemment les données de production — le tout assisté par l'API Mistral AI (gratuite).

<br/>

---

</div>

## 📋 Table des matières

- [🎯 Présentation](#-présentation)
- [💡 Le problème résolu](#-le-problème-résolu)
- [🏗️ Architecture générale](#️-architecture-générale)
- [🔗 La liaison intelligente](#-la-liaison-intelligente)
- [🛡️ Composante 1 — depguard](#️-composante-1--depguard)
- [📊 Composante 2 — Agents données](#-composante-2--agents-données)
- [🧠 Composante 3 — LLM et Agent Insight](#-composante-3--llm-et-agent-insight)
- [🤖 Rôle précis du LLM](#-rôle-précis-du-llm)
- [⚙️ Options et fonctionnalités](#️-options-et-fonctionnalités)
- [🛡️ Gestion des erreurs](#️-gestion-des-erreurs)
- [📊 Journalisation](#-journalisation)
- [✅ Conformité aux exigences](#-conformité-aux-exigences)
- [🧪 Scénarios de test](#-scénarios-de-test)
- [📦 Structure du projet](#-structure-du-projet)
- [👥 Division des tâches](#-division-des-tâches)

---

## 🎯 Présentation

**mindctl** (*Mind Control*) est un outil en ligne de commande Linux développé en Bash et C qui orchestre deux composantes liées intelligemment :

- **depguard** : corrige les conflits de configuration DevOps, vérifie la compatibilité du système Linux, lance le projet et diagnostique les échecs via l'API Mistral AI
- **Agents données** : nettoient, transforment et analysent les données de production extraites automatiquement depuis la base de données détectée par depguard

```
mindctl [OPTIONS] -p <projet_ou_fichier>
```

---

## 💡 Le problème résolu

Un développeur ou DevOps déploie son projet sur une machine Linux (locale, AWS EC2, VPS) et passe des heures à comprendre pourquoi ça ne fonctionne pas. Les fichiers de configuration se contredisent, le système n'a pas les bonnes versions, et quand tout semble correct le projet échoue au démarrage sans explication claire. Ensuite, personne n'analyse les données de production pour détecter les anomalies avant qu'elles causent des incidents.

| Sans mindctl | Avec mindctl |
|---|---|
| Lire 5 fichiers de config manuellement | Scan automatique de tous les fichiers |
| Chercher les contradictions pendant des heures | Conflits détectés et expliqués par LLM |
| Vérifier le système manuellement | Compatibilité système vérifiée automatiquement |
| Déboguer l'échec sans piste | Cause identifiée par LLM + correction proposée |
| Analyser les données manuellement | Données extraites et analysées automatiquement |
| **Durée : 3 à 4 heures** | **Durée : 30 secondes** |

---

## 🏗️ Architecture générale

```
mindctl (chef d'orchestre)
         │
         ├──────────────────────────────────┐
         │                                  │
         ▼                                  ▼
  ┌─────────────┐                  ┌────────────────┐
  │  depguard   │                  │ Agents Données │
  │ DevOps cycle│                  │ CSV / JSON / DB│
  └──────┬──────┘                  └───────┬────────┘
         │                                 │
         │    liaison intelligente          │
         └────────────────────────────────►│
         │  (credentials DB transmis)      │
         │                                 │
         ▼                                 ▼
  ┌─────────────────────────────────────────────┐
  │         Mistral AI API (api.mistral.ai)      │
  │  cerveau commun aux deux composantes         │
  └─────────────────────────────────────────────┘
         │
         ▼
  ┌─────────────┐
  │   insight   │
  │  corrélation│
  │   croisée   │
  └─────────────┘
```

---

## 🔗 La liaison intelligente

C'est le point central qui unit les deux composantes en un pipeline cohérent.

Après avoir détecté et lancé la base de données, **depguard transmet automatiquement** les informations de connexion aux agents données via un fichier de contexte partagé `/tmp/mindctl_context.env` :

```
depguard lit docker-compose.yml et détecte :
→ PostgreSQL sur port 5432
→ credentials : admin / secret
→ base de données : myapp
→ statut : RUNNING

depguard écrit dans /tmp/mindctl_context.env
→ DB_TYPE, DB_PORT, DB_USER, DB_PASS, DB_NAME

Les agents données lisent ce contexte
→ se connectent directement à la base
→ extraient, nettoient et analysent les données
→ sans aucune configuration manuelle
```

**Ce que cette liaison apporte :** deux composantes qui semblent séparées forment un pipeline unifié. depguard ne se contente plus de corriger la config — il prépare aussi le terrain pour l'analyse des données de production.

---

## 🛡️ Composante 1 — depguard

depguard est dédié au développeur ou DevOps qui travaille directement sur sa machine Linux sans virtualisation. Il est particulièrement utile lors d'un déploiement sur une machine cloud nue (AWS EC2, VPS) où chaque erreur de configuration coûte du temps.

### Logique de démarrage — vérification du lockfile

Avant toute action, depguard vérifie si un fichier `depguard.lock` existe :

```
depguard.lock existe ?
        │
        ├── OUI + rien changé    → "environnement déjà validé ✅"
        │                          option : forcer une nouvelle analyse
        │
        ├── OUI + changements    → afficher exactement ce qui a changé
        │                          choix :
        │                          1. Restaurer l'état du lockfile
        │                          2. Re-analyser et corriger
        │                          3. Ignorer
        │
        └── NON                  → lancer l'analyse complète (3 étapes)
```

---

### Étape 1 — Détection des conflits entre fichiers de configuration

**Outils Linux utilisés :** `find`, `grep`, `awk`, `sed`, `curl`

depguard scanne automatiquement tous les fichiers de configuration du projet et détecte les contradictions à deux niveaux :

**Niveau Bash (conflits évidents) :**
- Deux versions différentes du même outil déclarées dans deux fichiers différents
- Un port dans `.env` qui ne correspond pas au port dans `docker-compose.yml`
- Une variable `DB_HOST=localhost` qui devrait être `DB_HOST=database` en production Docker

**Niveau LLM (incohérences profondes) :**
- Le contenu complet de tous les fichiers est envoyé au LLM
- Le LLM comprend le sens de chaque déclaration dans son contexte
- Il propose la valeur unifiée correcte et explique pourquoi

**Fichiers analysés :**

| Fichier | Ce que depguard en extrait |
|---------|--------------------------|
| `Dockerfile` | Version de l'image de base |
| `docker-compose.yml` | Services, ports, variables d'environnement |
| `package.json` | Version Node.js requise |
| `requirements.txt` | Dépendances Python |
| `pom.xml` | Version Java |
| `.env` | Variables et valeurs |
| `nginx.conf` | Configuration réseau et ports |

**Correction :** après accord de l'utilisateur, `sed` applique les corrections directement dans les fichiers. Une sauvegarde `.backup` est créée avant toute modification.

> **Rôle du LLM ici :** comprendre *quel* conflit choisir et *pourquoi*. Bash détecte la différence, le LLM comprend le sens.

---

### Prérequis

```bash
# Installer les dépendances système
sudo apt install curl gcc jq

# Obtenir une clé API Mistral AI gratuite
# → https://console.mistral.ai → Sign Up → API Keys → Create key
# → Copier la clé dans mindctl.conf
```

---

### Étape 2 — Vérification de la compatibilité du système Linux

**Outils Linux utilisés :** `node --version`, `docker --version`, `lsof`, `df`, `free`

Même avec des fichiers parfaitement cohérents, le projet peut échouer si la machine Linux elle-même n'est pas prête.

depguard vérifie :
- La version des outils installés vs versions requises par le projet
- La disponibilité de Docker et des autres outils nécessaires
- La disponibilité des ports déclarés dans la configuration
- L'espace disque et la mémoire RAM suffisants

```
[depguard] Vérification système...

CRITIQUE  node    → requis:18  /  installé:14
CRITIQUE  docker  → non installé
WARNING   port    → 5000 déjà occupé par nginx
```

> **Rôle du LLM ici :** aucun. Les commandes Linux standards suffisent. Le LLM n'est pas utilisé là où Bash peut faire le travail seul.

---

### Étape 3 — Lancement du projet et diagnostic intelligent

**Outils Linux utilisés :** `docker-compose`, `curl`, `tee`

depguard lance le projet, capture tout ce qui se passe au démarrage, et vérifie que chaque service répond.

**Si le projet démarre avec succès :**
```
[depguard] Projet opérationnel ✅

  ✅ App        → http://localhost:5000  (200ms)
  ✅ PostgreSQL → port 5432             (connecté)
  ✅ Redis      → port 6379             (PONG)
```

**Si le projet échoue :**
```
[depguard] Échec au démarrage ❌

Cause LLM : l'app démarre avant que PostgreSQL soit prêt
Correction : ajouter depends_on dans docker-compose.yml

Appliquer et relancer ? (o/n) :
```

> **Rôle du LLM ici :** identifier la cause racine d'un échec que Bash ne peut pas interpréter seul.

---

### Génération du lockfile — depguard.lock

Après un déploiement réussi, depguard génère automatiquement `depguard.lock` qui capture l'état exact et validé de l'environnement.

```
[meta]
date      = 2026-04-17-10-30-00
projet    = monprojet
statut    = OPERATIONNEL

[versions_unifiees]
node      = 18
python    = 3.11

[ports_valides]
app       = 5000
db        = 5432

[systeme_valide]
os        = Ubuntu 22.04
ram_min   = 4GB
disque    = 10GB libres
```

**3 utilisations concrètes du lockfile :**

**1. Partage en équipe :** un coéquipier clone le projet et lance `mindctl -a depguard --from-lock`. Il obtient le même environnement en 5 secondes sans rien analyser.

**2. Détection de régression :** `mindctl -a depguard --check` compare l'état actuel au lockfile et signale exactement ce qui a changé depuis la dernière validation.

**3. Documentation automatique :** le lockfile répond à toutes les questions d'un nouveau développeur (versions, ports, variables) sans que personne n'ait rien écrit manuellement.

---

## 📊 Composante 2 — Agents données

### Les quatre agents

| Agent | Rôle | Outils Linux |
|-------|------|-------------|
| `cleaner` | Se connecte à la base via le contexte depguard, extrait les données en CSV, supprime doublons, lignes vides et valeurs nulles | `sort`, `uniq`, `grep`, `awk` |
| `transformer` | Convertit les formats CSV vers JSON et inversement | `awk`, `sed` |
| `analyzer` | Calcule les statistiques (moyennes, valeurs nulles, anomalies) et envoie au LLM pour interprétation | `awk`, `curl` |
| `validator` | Vérifie la structure et le format des données extraites | expressions régulières Bash |

> **Rôle du LLM dans analyzer :** interpréter le sens des chiffres. `awk` calcule que 23% des valeurs sont nulles. Le LLM comprend si c'est grave, quelle en est la cause probable, et quelle action recommander.

### Modes d'exécution parallèle — Modules C

Les modules C sont nécessaires car `fork()` et `pthreads` sont des appels système Linux accessibles uniquement via le langage C. Bash ne peut pas les implémenter nativement.

| Mode | Implémentation | Usage | Temps |
|------|---------------|-------|-------|
| `-s` subshell | Bash natif `( )` | 1 table, traitement léger | ~2s |
| `-f` fork | `fork_agent.c` avec `fork()` et `waitpid()` | 5-10 tables, isolation totale | ~8s |
| `-t` threads | `thread_agent.c` avec `pthreads` | 50+ tables, parallélisme maximal | ~15s |
| Sans parallélisme | Séquentiel | 50 tables | ~180s |

**Justification fork :** chaque table est traitée dans un processus fils indépendant. Si le traitement d'une table échoue, les autres continuent sans être affectés.

**Justification threads :** toutes les tables sont analysées simultanément dans le même processus. Plus léger que fork, idéal pour de grandes quantités de données.

---

## 🧠 Composante 3 — API Mistral AI et Agent Insight

### Agent insight — La corrélation croisée

L'agent insight est la fonctionnalité la plus unique de mindctl. Il reçoit les résultats de depguard ET des agents données, et demande au LLM de trouver les liens entre les deux sources.

```
Résultats depguard  →  erreur disque détectée à 09h15
Résultats données   →  anomalie dans la table orders à 09h15
                                │
                                ▼
         [insight] envoie les deux au LLM

         LLM répond :
         "L'erreur disque à 09h15 correspond exactement
          au pic d'anomalies dans la table orders.
          Cause probable : l'écriture incomplète due
          à la surcharge disque a produit des lignes
          corrompues. Vérifiez les lignes entre
          09h10 et 09h20 avant utilisation."
```

C'est ce que ni un outil DevOps seul, ni un outil d'analyse de données seul ne peut faire.

---

## 🤖 Rôle précis de l'API Mistral AI

L'API Mistral AI n'est pas appelée partout. Elle est utilisée **uniquement** là où Bash seul ne peut pas comprendre le sens de ce qu'il voit.

| Endroit | Mistral AI ? | Pourquoi |
|---------|-------|---------|
| depguard Étape 1 — conflits config | ✅ Oui | Comprendre quel conflit choisir et pourquoi |
| depguard Étape 3 — diagnostic démarrage | ✅ Oui | Identifier la cause racine d'un échec |
| analyzer — interprétation statistiques | ✅ Oui | Comprendre le sens des anomalies |
| insight — corrélation croisée | ✅ Oui | Relier anomalies config et données |
| cleaner, transformer, validator | ❌ Non | grep, sort, uniq, sed suffisent |
| Vérification système (Étape 2) | ❌ Non | Les commandes Linux suffisent |
| Correction des fichiers | ❌ Non | sed applique, Mistral AI décide seulement |

> L'API Mistral AI est le **cerveau**, les outils Linux sont les **bras**.

---

## ⚙️ Options et fonctionnalités

```
SYNOPSIS
    mindctl [OPTIONS] -p <paramètre>

OPTIONS OBLIGATOIRES
    -p <chemin>     Fichier, dossier ou projet à analyser (OBLIGATOIRE)

OPTIONS PRINCIPALES
    -h              Affiche cette aide détaillée
    -f              Exécution via fork()   — processus fils isolé (C)
    -t              Exécution via threads  — parallélisme pthreads (C)
    -s              Exécution via subshell — environnement isolé Bash
    -l <dossier>    Dossier de stockage des logs
    -r              Réinitialise la configuration (admin requis)

OPTIONS AVANCÉES
    -a <agent>      Choisit l'agent : depguard | cleaner | analyzer |
                                      transformer | validator | insight
    -w              Mode pipeline : chaîne les agents automatiquement
    --from-lock     Applique directement le lockfile existant
    --check         Compare l'état actuel au lockfile
    --restore       Restaure l'état validé du lockfile
```

---

## 🛡️ Gestion des erreurs

Chaque erreur produit un code spécifique et affiche automatiquement l'aide `-h` :

| Code | Description |
|------|-------------|
| `100` | Option inexistante |
| `101` | Paramètre `-p` manquant |
| `102` | Fichier ou dossier introuvable |
| `103` | Permission refusée (sans root) |
| `104` | Format de fichier non supporté |
| `105` | LLM inaccessible → bascule en mode classique automatiquement |
| `106` | Agent inconnu |
| `107` | Échec du traitement |

```
$ mindctl -a depguard
[ERREUR 101] Paramètre obligatoire manquant : -p <fichier>

UTILISATION : mindctl [options] -p <paramètre>
...
```

---

## 📊 Journalisation

Toutes les sorties sont redirigées **simultanément** vers le terminal et vers `/var/log/mindctl/history.log` via `tee`.

**Format imposé par le prof :**
```
yyyy-mm-dd-hh-mm-ss : username : INFOS : message
yyyy-mm-dd-hh-mm-ss : username : ERROR : message d'erreur
```

**Exemple réel :**
```
2026-04-17-10-30-00 : root : INFOS : depguard démarré sur ./monprojet
2026-04-17-10-30-01 : root : INFOS : 3 conflits détectés dans les fichiers config
2026-04-17-10-30-03 : root : INFOS : Corrections appliquées avec succès
2026-04-17-10-30-04 : root : INFOS : Système Linux compatible ✅
2026-04-17-10-30-06 : root : INFOS : Projet lancé — tous services opérationnels
2026-04-17-10-30-07 : root : INFOS : Contexte DB transmis aux agents données
2026-04-17-10-30-09 : root : INFOS : cleaner — 487 doublons supprimés
2026-04-17-10-30-11 : root : INFOS : analyzer — 3 anomalies détectées
2026-04-17-10-30-12 : root : INFOS : insight — corrélation détectée entre config et données
2026-04-17-10-30-12 : root : ERROR : Thread 3 timeout après 30s
```

---

## ✅ Conformité aux exigences

### 3.2.1 — Besoin réel et original ✅
Corriger les conflits de configuration DevOps, vérifier la compatibilité système, diagnostiquer les échecs de déploiement, et analyser les données de production en pipeline unifié — besoin quotidien de tout développeur et DevOps déployant sur Linux.

### 3.2.2 — 6 options obligatoires ✅
`-h` `-f` `-t` `-s` `-l` `-r` + options avancées `-a` `-p` `-w` `--from-lock` `--check` `--restore`

### 3.2.2 — Paramètre obligatoire ✅
`-p <chemin>` est obligatoire. Son absence déclenche l'erreur `101`.

### 3.2.2 — Commandes Unix/Linux ✅
`curl`, `grep`, `awk`, `sed`, `tee`, `find`, `sort`, `uniq`, `tar`, `lsof`, `df`, `free`, `docker`, `psql`

### 3.2.2 — Concepts shell ✅

| Concept | Utilisation dans mindctl |
|---------|--------------------------|
| Conditions | Vérifier LLM, existence fichier, droits root, type de base |
| Boucles | Parcourir fichiers de config et tables de la base |
| Fonctions | `appeler_llm()`, `log_message()`, `check_root()` |
| Variables d'environnement | `MINDCTL_MODEL`, `MINDCTL_LOG_DIR` |
| Expressions régulières | Valider formats, détecter versions, filtrer anomalies |
| Pipes et filtres | Chaînage grep, awk, sed, curl pour chaque traitement |
| Contrôle d'accès | `-r` réservé à root via `[[ $EUID -ne 0 ]]` |
| Archivage/compression | `tar -czf` automatique des anciens rapports |

### 3.2.4 — 3 scénarios de test ✅

| Scénario | Description | Mode |
|----------|-------------|------|
| 🟢 Léger | 1 fichier config, correction simple, 1 table nettoyée | `-s` subshell |
| 🟡 Moyen | depguard config complète + 10 tables en parallèle | `-f` fork |
| 🔴 Lourd | Pipeline complet depguard + 50 tables + insight | `-t` threads + `-w` |

---

## 🧪 Scénarios de test

### Scénario 1 — Léger (subshell)
```bash
mindctl -a depguard -p ./projet -s
# 1 fichier de config, correction simple
# Temps attendu : ~2 secondes
```

### Scénario 2 — Moyen (fork)
```bash
mindctl -a depguard -f -p ./projet
# Config complète + 10 tables analysées en parallèle
# Temps attendu : ~8 secondes
```

### Scénario 3 — Lourd (threads + pipeline complet)
```bash
mindctl -w -p ./projet -t
# Pipeline complet : depguard + 50 tables + insight corrélation
# Temps attendu : ~15 secondes
```

---

## 📦 Structure du projet

```
mindctl/
│
├── mindctl.sh                    ← Script principal (chef d'orchestre)
│
├── agents/
│   ├── depguard.sh               ← Cycle DevOps complet (3 étapes + lockfile)
│   ├── cleaner.sh                ← Nettoyage données de production
│   ├── analyzer.sh               ← Analyse statistique + interprétation LLM
│   ├── transformer.sh            ← Conversion formats CSV/JSON
│   ├── validator.sh              ← Validation structure des données
│   └── insight.sh                ← Corrélation croisée config + données
│
├── core/
│   ├── logger.sh                 ← log_message() partagée par tous
│   ├── llm.sh                    ← appeler_llm() partagée par tous
│   └── errors.sh                 ← Codes d'erreur + affichage aide
│
├── helpers/
│   ├── fork_agent.c              ← Module C pour fork()
│   └── thread_agent.c            ← Module C pour pthreads
│
├── exemple/
│   ├── test_leger/               ← Scénario léger
│   ├── test_moyen/               ← Scénario moyen
│   └── test_lourd/               ← Scénario lourd
│
├── mindctl.conf                  ← Configuration
└── README.md                     ← Ce fichier
```

---

## 👥 Division des tâches

> Projet réalisé dans le cadre du module **Théorie des Systèmes d'Exploitation & SE Windows/Unix/Linux**
> ENSET Mohammedia — Université Hassan II de Casablanca — 2026

---

### 📅 Planning général

| Semaine | Personne 1 | Personne 2 | Personne 3 |
|---------|-----------|-----------|-----------|
| Semaine 1 | `mindctl.sh` + `depguard` étapes 1 et 2 | `fork_agent.c` + `thread_agent.c` + `cleaner.sh` | `appeler_llm()` + `analyzer.sh` |
| Semaine 2 | `depguard` étape 3 + lockfile | `transformer.sh` + `validator.sh` | `insight.sh` + liaison avec depguard |
| Semaine 3 | Tests + corrections + `-h` complet | Tests modules C + scénarios | Préparation démo + rapport PDF |

---

### 👤 Personne 1 — Script principal + depguard

> **Rôle :** chef technique du projet. Responsable du cœur de mindctl et du cycle DevOps complet via depguard.

#### 1. Le script principal `mindctl.sh`

C'est le point d'entrée de tout le projet. Il reçoit les commandes de l'utilisateur, parse les options, et appelle les bons agents.

**Ce que tu dois implémenter :**

- Parser toutes les options avec `getopts` : `-h`, `-f`, `-t`, `-s`, `-l`, `-r`, `-a`, `-p`, `-w`
- Vérifier que `-p` est présent — si absent, déclencher l'erreur `101` et afficher l'aide
- Détecter automatiquement le mode d'exécution (subshell, fork, thread)
- Vérifier les droits root pour l'option `-r` avec `[[ $EUID -ne 0 ]]`
- Implémenter le mode pipeline `-w` qui enchaîne les agents automatiquement
- Afficher l'aide complète avec `-h`
- Déclencher l'affichage de l'aide après chaque erreur

#### 2. Le système de journalisation — `core/logger.sh`

**Cette fonction est partagée par tout le monde. Tu dois la créer en premier et la partager.**

Le format exact imposé par le prof :
```
yyyy-mm-dd-hh-mm-ss : username : INFOS : message
yyyy-mm-dd-hh-mm-ss : username : ERROR : message d'erreur
```

La fonction `log_message()` doit écrire simultanément dans le terminal et dans `/var/log/mindctl/history.log` via `tee`.

#### 3. L'agent `depguard.sh`

**Étape 1 — Détection des conflits :**
- Utiliser `find` pour scanner tous les fichiers de config
- Utiliser `grep` et `awk` pour extraire les versions et ports
- Comparer les valeurs et détecter les contradictions
- Appeler `appeler_llm()` (créée par Personne 3) pour l'analyse profonde
- Utiliser `sed` pour appliquer les corrections après accord utilisateur
- Créer des sauvegardes `.backup` avant toute modification

**Étape 2 — Vérification système :**
- Vérifier les versions des outils avec `node --version`, `docker --version`, `python3 --version`
- Vérifier les ports libres avec `lsof`
- Vérifier l'espace disque avec `df` et la RAM avec `free`
- Afficher les problèmes détectés avec leur niveau de gravité

**Étape 3 — Lancement et diagnostic :**
- Lancer le projet avec `docker-compose up`
- Capturer les logs avec `tee`
- Vérifier que les services répondent avec `curl`
- En cas d'échec, appeler `appeler_llm()` avec les logs pour diagnostic
- Proposer la correction et relancer après accord

**Lockfile :**
- Générer `depguard.lock` après succès
- Implémenter la logique de vérification avant analyse
- Implémenter `--from-lock`, `--check`, `--restore`

#### 4. Gestion des erreurs — `core/errors.sh`

Implémenter les 8 codes d'erreur avec affichage automatique de l'aide après chaque erreur déclenchée.

#### 5. Fichiers à livrer

```
mindctl.sh
agents/depguard.sh
core/logger.sh
core/errors.sh
```

---

### 👤 Personne 2 — Agents données + Modules C

> **Rôle :** responsable de la performance et du traitement des données. Tu gères le parallélisme en C et le nettoyage/analyse des données de production.

#### 1. Le module Fork — `helpers/fork_agent.c`

Le fork crée un processus fils pour chaque table à analyser. Si un traitement échoue, les autres continuent sans problème.

**Ce que tu dois implémenter :**
- Appel système `fork()` pour créer un processus fils par agent
- `waitpid()` pour que le père attende la fin de tous les fils
- Récupération du code de retour de chaque fils
- Gestion du cas où un fils plante sans tuer le père

**Commande de compilation :**
```bash
gcc fork_agent.c -o fork_agent
```

#### 2. Le module Thread — `helpers/thread_agent.c`

Les threads analysent plusieurs tables simultanément dans le même processus.

**Ce que tu dois implémenter :**
- `pthread_create()` pour lancer un thread par table
- `pthread_join()` pour attendre la fin de tous les threads
- Mutex pour éviter les conflits d'écriture dans les fichiers de log
- Structure de données pour passer le nom de la table à chaque thread

**Commande de compilation :**
```bash
gcc thread_agent.c -o thread_agent -lpthread
```

#### 3. Les agents données

**`agents/cleaner.sh` :**
- Lire le contexte de depguard depuis `/tmp/mindctl_context.env`
- Se connecter à la base PostgreSQL/MySQL via les credentials transmis
- Extraire les données en CSV
- Supprimer les lignes vides avec `grep -v '^$'`
- Supprimer les doublons avec `sort | uniq`
- Supprimer les valeurs nulles avec `awk`
- Logger le nombre de lignes supprimées

**`agents/transformer.sh` :**
- Lire le contexte de depguard
- Convertir CSV vers JSON avec `awk`
- Convertir JSON vers CSV avec `sed` et `awk`

**`agents/validator.sh` :**
- Vérifier la structure du fichier extrait
- Valider les formats avec des expressions régulières (emails, dates, nombres)
- Vérifier le nombre de colonnes cohérent sur toutes les lignes
- Signaler les anomalies de structure

#### 4. Fichiers à livrer

```
helpers/fork_agent.c
helpers/thread_agent.c
agents/cleaner.sh
agents/transformer.sh
agents/validator.sh
```

---

### 👤 Personne 3 — LLM + Agent Insight + Tests

> **Rôle :** responsable de l'intelligence du projet et de la démonstration finale. Tu crées le cerveau commun utilisé par toutes les composantes.

#### 1. La fonction API Mistral AI — `core/llm.sh`

**Cette fonction est partagée par tout le monde. Tu dois la créer et la partager dès le début.**

**Prérequis :**
- Créer un compte gratuit sur [console.mistral.ai](https://console.mistral.ai)
- Générer une API key gratuite
- La stocker dans `mindctl.conf` : `MISTRAL_API_KEY=votre_clé_ici`

**Ce que tu dois implémenter :**
- Lire la clé API depuis `mindctl.conf`
- Si clé absente ou invalide, déclencher l'erreur `105` et basculer en mode classique
- Envoyer le prompt à l'API Mistral AI via `curl` vers `https://api.mistral.ai/v1/chat/completions`
- Utiliser le modèle `mistral-small-latest` (gratuit et rapide)
- Parser la réponse JSON pour extraire uniquement le texte de la réponse
- Logger chaque appel API (temps de réponse, statut)

#### 2. L'agent Analyzer — `agents/analyzer.sh`

- Lire le contexte de depguard depuis `/tmp/mindctl_context.env`
- Se connecter à la base et exécuter des requêtes statistiques
- Calculer avec `awk` : total de lignes, valeurs nulles, valeurs uniques, moyennes
- Envoyer les statistiques à `appeler_llm()` pour interprétation
- Afficher les recommandations du LLM de façon claire et concise

#### 3. L'agent Insight — `agents/insight.sh`

C'est l'agent le plus important après depguard.

**Ce que tu dois implémenter :**
- Lire les résultats de depguard depuis `/var/log/mindctl/reports/last_depguard.txt`
- Lire les résultats des agents données depuis `/var/log/mindctl/reports/last_data.txt`
- Construire un prompt de corrélation qui envoie les deux sources au LLM
- Demander au LLM de trouver les liens entre les anomalies de config et les anomalies de données
- Afficher la corrélation détectée de façon claire

#### 4. Préparation des fichiers de test

**Créer dans `exemple/` :**
- `test_leger/` : 1 projet simple avec 1 fichier de config et 1 table
- `test_moyen/` : projet avec 3 fichiers de config et 10 tables
- `test_lourd/` : projet complet avec 5 fichiers de config et 50 tables

**Créer `demo.sh` :** script qui enchaîne les 3 scénarios automatiquement pour la présentation devant le prof.

#### 5. Fichiers à livrer

```
core/llm.sh
agents/analyzer.sh
agents/insight.sh
exemple/test_leger/
exemple/test_moyen/
exemple/test_lourd/
demo.sh
```

---

### 🔗 Points de coordination entre les 3 membres

> Ces 3 éléments doivent être définis **ensemble dès le premier jour** avant que chacun commence à coder.

**1. `log_message()`** → créée par Personne 1, utilisée par tous
```
Signature : log_message "INFOS" "message"
            log_message "ERROR" "message d'erreur"
```

**2. `appeler_llm()`** → créée par Personne 3, utilisée par tous
```
Signature : appeler_llm "votre prompt ici"
Retour    : texte de la réponse du LLM
```

**3. `/tmp/mindctl_context.env`** → écrit par depguard, lu par agents données
```
Contenu : DB_TYPE, DB_PORT, DB_USER, DB_PASS, DB_NAME, PROJECT_STATUS
```

**4. Fichier de configuration `mindctl.conf`** → structure fixée ensemble
```
MINDCTL_MODEL=mistral-small-latest
MINDCTL_LOG_DIR=/var/log/mindctl
MISTRAL_API_KEY=votre_clé_api_ici
LLM_URL=https://api.mistral.ai/v1/chat/completions
```

---

<div align="center">

**Date limite de soumission : 14/05/2026 à 23:59:59**

---

*ENSET Mohammedia © 2026 — Tous droits réservés*

</div>
