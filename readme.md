<div align="center">

```
███╗   ███╗██╗███╗   ██╗██████╗  ██████╗████████╗██╗
████╗ ████║██║████╗  ██║██╔══██╗██╔════╝╚══██╔══╝██║
██╔████╔██║██║██╔██╗ ██║██║  ██║██║        ██║   ██║
██║╚██╔╝██║██║██║╚██╗██║██║  ██║██║        ██║   ██║
██║ ╚═╝ ██║██║██║ ╚████║██████╔╝╚██████╗   ██║   ███████╗
╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝   ╚═╝   ╚══════╝
```

**Orchestrateur Intelligent de Données et de Système**

[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![C](https://img.shields.io/badge/C-99-A8B9CC?style=for-the-badge&logo=c&logoColor=white)](https://en.wikipedia.org/wiki/C99)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![LLM](https://img.shields.io/badge/LLM-Ollama%2FMistral-7C3AED?style=for-the-badge&logo=ollama&logoColor=white)](https://ollama.ai/)
[![License](https://img.shields.io/badge/Licence-ENSET%202026-0EA5E9?style=for-the-badge)](.)

<br/>

> 🤖 **mindctl** est un orchestrateur d'agents IA en Bash qui analyse automatiquement vos **logs système** ET vos **fichiers de données** (CSV, JSON), détecte les corrélations intelligentes entre les deux, et vous envoie des rapports complets — le tout en ligne de commande Linux.

<br/>

---

</div>

## 📋 Table des matières

- [🎯 Présentation du projet](#-présentation-du-projet)
- [💡 Idée et contexte](#-idée-et-contexte)
- [🤖 Les agents disponibles](#-les-agents-disponibles)
- [⚙️ Options et fonctionnalités](#️-options-et-fonctionnalités)
- [🔀 Modes d'exécution](#-modes-dexécution)
- [💬 Mode interactif](#-mode-interactif)
- [📧 Notifications email](#-notifications-email)
- [📁 Ce que mindctl exploite](#-ce-que-mindctl-exploite)
- [🛡️ Gestion des erreurs](#️-gestion-des-erreurs)
- [📊 Journalisation](#-journalisation)
- [✅ Conformité aux exigences du prof](#-conformité-aux-exigences-du-prof)
- [🚀 Installation et utilisation](#-installation-et-utilisation)
- [🧪 Scénarios de test](#-scénarios-de-test)
- [📦 Structure du projet](#-structure-du-projet)
- [👥 Équipe](#-équipe)

---

## 🎯 Présentation du projet

**mindctl** (*Mind Control*) est un outil en ligne de commande Linux développé en Bash et C, qui orchestre plusieurs **agents IA spécialisés** pour analyser intelligemment deux types de données :

- 🖥️ **Données système** : logs Linux, métriques CPU/RAM/disque, fichiers de configuration
- 📊 **Données fichiers** : CSV, JSON, TXT bruts issus de pipelines Big Data

La puissance unique de mindctl réside dans sa capacité à **croiser les deux sources** pour détecter des corrélations invisibles à l'œil humain.

```
mindctl [options] -p <fichier_ou_dossier>
```

---

## 💡 Idée et contexte

### Le problème

Un développeur ou administrateur système fait face chaque jour à **deux problèmes distincts mais liés** :

**Problème 1 — Côté système :**
Des centaines de lignes de logs illisibles, des alertes incompréhensibles, un serveur lent sans raison apparente.

**Problème 2 — Côté données :**
Des fichiers CSV mal formatés, des JSON désorganisés, des doublons et valeurs nulles impossibles à exploiter directement.

Sans outil adapté, il jongle entre plusieurs programmes, perd des heures, et rate souvent les corrélations entre les deux sources.

### La solution : mindctl

```
Sans mindctl                        Avec mindctl
──────────────────────────          ──────────────────────────────────
Lire 500 lignes de logs    ──→      mindctl -a summarizer -p /var/log/syslog
Nettoyer CSV manuellement  ──→      mindctl -a cleaner -p dataset.csv
Chercher des corrélations  ──→      mindctl -w -p /var/log/ -p dataset.csv
Écrire un rapport          ──→      Rapport généré + envoyé par email
Durée : 3 heures           ──→      Durée : 15 secondes ✅
```

### La valeur unique : la corrélation croisée

```
Logs système  ──→  erreur Disk I/O à 09:15
Données CSV   ──→  pic anormal dans les métriques à 09:15
                              │
                              ▼
         [agent insight] Corrélation détectée :
         La surcharge disque a causé l'anomalie dans vos données
```

C'est ce que ni un outil système seul, ni un outil Big Data seul ne peut faire.

### Pourquoi c'est innovant ?

- 🧠 **Agentic AI** : thème numéro 1 mondial en 2026
- 🔗 **Fusion unique** : système + données dans un seul outil
- 🐧 **100% Linux natif** : aucune dépendance externe lourde
- ⚡ **Pipeline multi-agents** : les agents se chaînent automatiquement
- 💬 **Mode interactif** : chat en temps réel avec l'agent dans le terminal
- 📧 **Notifications email** : rapport envoyé automatiquement

---

## 🤖 Les agents disponibles

### Branche Système

| Agent | Rôle | Commande exemple |
|-------|------|-----------------|
| 🔍 `summarizer` | Résume et explique un fichier log | `mindctl -a summarizer -p /var/log/syslog` |
| 🗂️ `classifier` | Classe les erreurs par catégorie et gravité | `mindctl -a classifier -p /var/log/auth.log` |
| 📊 `monitor` | Analyse CPU, RAM, disque, réseau en temps réel | `mindctl -a monitor` |
| 💻 `coder` | Analyse un script et détecte les bugs | `mindctl -a coder -p monscript.sh` |

### Branche Données

| Agent | Rôle | Commande exemple |
|-------|------|-----------------|
| 🧹 `cleaner` | Supprime doublons, nulls, lignes vides | `mindctl -a cleaner -p data.csv` |
| 🔄 `transformer` | Convertit formats CSV ↔ JSON | `mindctl -a transformer -p data.json` |
| 📈 `analyzer` | Statistiques : moyennes, écarts, anomalies | `mindctl -a analyzer -p data.csv` |
| ✅ `validator` | Vérifie la structure et le format du fichier | `mindctl -a validator -p data.json` |

### Agent Fusion

| Agent | Rôle | Commande exemple |
|-------|------|-----------------|
| 🧠 `insight` | Corrélation croisée système + données via LLM | `mindctl -a insight -p /var/log/ -p data.csv` |

---

## ⚙️ Options et fonctionnalités

```
SYNOPSIS
    mindctl [OPTIONS] -p <paramètre>

OPTIONS OBLIGATOIRES
    -p <chemin>       Fichier, dossier ou texte à analyser (OBLIGATOIRE)

OPTIONS PRINCIPALES
    -h                Affiche cette aide détaillée
    -f                Exécution via fork()    — processus fils isolé (C)
    -t                Exécution via threads   — parallélisme pthreads (C)
    -s                Exécution via subshell  — environnement isolé Bash
    -l <dossier>      Dossier de stockage des logs (défaut: /var/log/mindctl)
    -r                Réinitialise la configuration (administrateur requis)

OPTIONS AVANCÉES
    -a <agent>        Choisit l'agent (voir liste des agents)
    -w                Mode pipeline : chaîne plusieurs agents automatiquement
    -i                Mode interactif : chat en temps réel avec l'agent
    -n email          Envoie le rapport par email après l'analyse
    -c                Nettoyage rapide sans passer par -a cleaner
    -z                Compression et archivage automatique après traitement
```

---

## 🔀 Modes d'exécution

mindctl propose **3 modes d'exécution** pour s'adapter à la charge de travail :

### 🔵 `-s` Subshell — Traitement léger

Le traitement s'exécute dans un sous-shell Bash isolé. Si le traitement échoue, le script principal continue sans être affecté.

```bash
mindctl -a cleaner -p data.csv -s
```

```
Shell principal
    └── (sous-shell) → nettoie data.csv → ferme proprement
```

**Quand l'utiliser :** 1 seul fichier, traitement simple.

---

### 🟡 `-f` Fork — Traitement moyen (C)

Chaque fichier est traité dans un **processus fils indépendant** via `fork()`. Si un traitement échoue, les autres continuent.

```bash
mindctl -a analyzer -p /data/ -f
```

```
Processus père (mindctl)
    ├── fork() → data1.csv   → analyse → résultat
    ├── fork() → data2.json  → analyse → résultat
    └── fork() → data3.txt   → analyse → résultat
```

**Quand l'utiliser :** 5 à 10 fichiers, traitements indépendants.

---

### 🔴 `-t` Threads — Traitement lourd (C + pthreads)

Plusieurs fichiers sont traités **simultanément** dans le même processus via `pthreads`. Plus léger que fork, idéal pour de grandes quantités de fichiers.

```bash
mindctl -a insight -p /data/ -t
```

```
Processus unique (mindctl)
    ├── Thread 1 → data1.csv   ──→ analyse LLM
    ├── Thread 2 → data2.json  ──→ analyse LLM
    ├── Thread 3 → syslog      ──→ analyse LLM
    └── Thread 4 → auth.log    ──→ analyse LLM
                               (tous simultanément)
```

**Quand l'utiliser :** 10 à 50 fichiers, pipeline complet.

---

### Comparaison des performances

| Mode | Fichiers | Temps estimé | Ressources |
|------|----------|-------------|------------|
| `-s` Subshell | 1 fichier | ~2s | Légères |
| `-f` Fork | 5-10 fichiers | ~5s | Moyennes |
| `-t` Threads | 50 fichiers | ~10s | Optimisées |
| Sans parallélisme | 50 fichiers | ~180s | — |

---

## 💬 Mode interactif

Le mode interactif `-i` permet de **discuter directement** avec l'agent IA dans le terminal. L'agent se souvient du contexte de la conversation et peut traiter aussi bien des logs que des fichiers CSV.

```bash
mindctl -i
```

```
╔══════════════════════════════════════════════════╗
║          mindctl — Mode Interactif v1.0          ║
║          Tapez 'help' pour les commandes         ║
╚══════════════════════════════════════════════════╝

[agent] Bonjour ! Je peux analyser vos logs et vos données.
        Que voulez-vous traiter ?

[vous]  analyse les erreurs dans /var/log/syslog

[agent] Lecture du fichier... Filtrage... Envoi au LLM...
        → 3 erreurs critiques détectées
        → Disk I/O error à 09:15 sur /dev/sda
        → SSH failed login x5 depuis 192.168.1.45

[vous]  j'ai aussi un fichier metrics.csv de cette période

[agent] Lecture de metrics.csv... Analyse croisée...
        → Pic anormal détecté dans metrics.csv à 09:15
        → Corrélation confirmée avec l'erreur Disk I/O
        → Cause probable : surcharge disque → données corrompues

[vous]  envoie le rapport par email

[agent] Rapport envoyé à admin@example.com ✅

[vous]  exit
[agent] Session terminée. Rapport → /var/log/mindctl/history.log
```

### Commandes disponibles en mode interactif

| Commande | Action |
|----------|--------|
| `analyse <fichier>` | Analyse logs ou données selon le type de fichier |
| `nettoie <fichier>` | Lance le cleaner sur un CSV/JSON |
| `monitore` | Affiche CPU/RAM/Disque en direct |
| `rapport` | Génère et envoie le rapport par email |
| `historique` | Affiche les 10 derniers échanges |
| `reset` | Efface la mémoire de la conversation |
| `help` | Affiche toutes les commandes disponibles |
| `exit` | Quitte le mode interactif |

> 💡 En mode interactif, les tâches lourdes sont automatiquement lancées en **fork** pour ne pas bloquer le chat.

---

## 📧 Notifications email

Avec l'option `-n email`, mindctl envoie automatiquement le rapport par email après chaque analyse.

```bash
mindctl -w -p /var/log/ -p data.csv -n email
```

```
De      : mindctl@votreserveur.com
À       : admin@example.com
Sujet   : [mindctl] Rapport — 2026-04-17 10:30:00

Pipeline  : système + données
Statut    : SUCCÈS ✅

Analyse système :
→ 3 erreurs critiques dans /var/log/syslog
→ Disque /dev/sda à 89% — CRITIQUE

Analyse données :
→ 487 doublons supprimés dans data.csv
→ Pic anormal détecté à 09:15

Corrélation IA :
→ La surcharge disque a causé les anomalies dans les données

Logs complets : /var/log/mindctl/history.log
```

### Configuration (`/etc/mindctl/mindctl.conf`)

```bash
NOTIFY_EMAIL="admin@example.com"
SMTP_SERVER="smtp.gmail.com"
LLM_MODEL="mistral"
LLM_URL="http://localhost:11434/api/generate"
LOG_DIR="/var/log/mindctl"
```

---

## 📁 Ce que mindctl exploite

```
mindctl exploite
    │
    ├── DONNÉES SYSTÈME
    │   ├── Logs Linux          /var/log/syslog, auth.log, kern.log...
    │   ├── Métriques           CPU (top), RAM (free), Disque (df), Réseau (netstat)
    │   ├── Fichiers de config  /etc/ssh/sshd_config, /etc/fstab...
    │   └── Historique shell    ~/.bash_history
    │
    ├── DONNÉES FICHIERS
    │   ├── CSV                 datasets, exports, métriques...
    │   ├── JSON                APIs, configurations, réponses...
    │   └── TXT                 logs applicatifs, rapports bruts...
    │
    └── SAISIE DIRECTE
        └── Questions libres en mode interactif -i
```

---

## 🛡️ Gestion des erreurs

Chaque erreur produit un **code spécifique** et affiche automatiquement l'aide `-h` :

| Code | Erreur |
|------|--------|
| `100` | Option inexistante |
| `101` | Paramètre `-p` manquant |
| `102` | Fichier ou dossier introuvable |
| `103` | Permission refusée (sans root) |
| `104` | Format de fichier non supporté |
| `105` | LLM inaccessible → bascule en mode classique |
| `106` | Agent inconnu |
| `107` | Échec du traitement |

```bash
$ mindctl -a cleaner
[ERREUR 101] Paramètre obligatoire manquant : -p <fichier>

UTILISATION : mindctl [options] -p <paramètre>
...
```

---

## 📊 Journalisation

Toutes les sorties sont redirigées **simultanément** vers le terminal et vers `/var/log/mindctl/history.log`.

### Format

```
yyyy-mm-dd-hh-mm-ss : username : INFOS : message
yyyy-mm-dd-hh-mm-ss : username : ERROR : message d'erreur
```

### Exemple réel

```
2026-04-17-10-30-00 : root : INFOS : Agent cleaner démarré
2026-04-17-10-30-01 : root : INFOS : Fichier data.csv lu (125430 lignes)
2026-04-17-10-30-03 : root : INFOS : 487 doublons supprimés
2026-04-17-10-30-04 : root : INFOS : Agent summarizer démarré
2026-04-17-10-30-06 : root : INFOS : Réponse LLM reçue en 2.1s
2026-04-17-10-30-07 : root : INFOS : Corrélation détectée entre logs et CSV
2026-04-17-10-30-08 : root : INFOS : Email envoyé à admin@example.com
2026-04-17-10-30-08 : root : ERROR : Thread 3 timeout après 30s
```

### Rapports individuels

```
/var/log/mindctl/reports/
├── report_2026-04-17-10-30-00_syslog.txt
├── report_2026-04-17-10-30-00_data.csv.txt
└── report_2026-04-17-10-30-00_insight.txt
```

---

## ✅ Conformité aux exigences du prof

### 3.2.1 — Besoin réel et original ✅
Fusion unique d'analyse système et de préparation de données avec corrélation IA — besoin quotidien réel de tout développeur et administrateur système.

### 3.2.2 — 6 options obligatoires ✅
`-h` `-f` `-t` `-s` `-l` `-r` + options avancées `-a` `-p` `-w` `-i` `-n` `-c` `-z`

### 3.2.2 — Paramètre obligatoire ✅
`-p <chemin>` est obligatoire. Son absence déclenche l'erreur `101`.

### 3.2.2 — Commandes Unix/Linux ✅
`curl`, `grep`, `awk`, `sed`, `tee`, `find`, `sort`, `uniq`, `tar`, `top`, `free`, `df`, `netstat`, `mail`, `inotifywait`

### 3.2.2 — Concepts shell ✅

| Concept | Utilisation dans mindctl |
|---------|--------------------------|
| Conditions | Vérifier Ollama, existence fichier, droits root, type de fichier |
| Boucles | Parcourir tous les fichiers d'un dossier |
| Fonctions | `launch_agent()`, `log_message()`, `check_root()`, `send_email()`, `detect_type()` |
| Variables d'environnement | `MINDCTL_MODEL`, `MINDCTL_LOG_DIR`, `MINDCTL_EMAIL` |
| Expressions régulières | Valider formats CSV/JSON, filtrer erreurs, détecter nulls |
| Pipes et filtres | `cat data.csv \| grep -v '^$' \| sort \| uniq \| awk ...` |
| Contrôle d'accès | `-r` réservé à root via `[[ $EUID -ne 0 ]]` |
| Archivage/compression | `tar -czf` automatique après traitement |

### 3.2.2 — Fork / Thread / Subshell ✅

| Mode | Justification dans mindctl |
|------|---------------------------|
| `-s` Subshell | Traitement léger d'un seul fichier en isolation |
| `-f` Fork | Chaque agent lancé en processus fils indépendant |
| `-t` Threads | Analyse simultanée de 50 fichiers via pthreads |

### 3.2.3 — Gestion d'erreurs ✅
8 codes d'erreur spécifiques + affichage automatique de l'aide après chaque erreur.

### 3.2.4 — 3 scénarios de test ✅

| Scénario | Description | Mode |
|----------|-------------|------|
| 🟢 Léger | 1 fichier CSV → agent cleaner | `-s` subshell |
| 🟡 Moyen | 10 fichiers logs + CSV → agents en parallèle | `-f` fork |
| 🔴 Lourd | Pipeline complet système + données sur 50 fichiers | `-t` threads + `-w` |

### 3.2.5 — Documentation ✅
Version simplifiée via `-h`. Version complète dans le PDF avec captures d'écran et exemples détaillés.

---

## 🚀 Installation et utilisation

### Prérequis

```bash
# Installer Ollama (LLM local gratuit)
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull mistral

# Installer les dépendances système
sudo apt install mailutils curl inotify-tools gcc
```

### Installation

```bash
git clone https://github.com/votre-equipe/mindctl.git
cd mindctl
chmod +x mindctl.sh
sudo cp mindctl.sh /usr/local/bin/mindctl

# Compiler les modules C
gcc fork_agent.c -o fork_agent
gcc thread_agent.c -o thread_agent -lpthread

# Créer les dossiers nécessaires
sudo mkdir -p /var/log/mindctl/reports
sudo mkdir -p /etc/mindctl
```

### Exemples d'utilisation

```bash
# Analyser un fichier log
mindctl -a summarizer -p /var/log/syslog -s

# Nettoyer un fichier CSV
mindctl -a cleaner -p dataset.csv -s

# Analyser un dossier entier en parallèle
mindctl -a analyzer -p /data/ -t

# Pipeline complet système + données avec email
mindctl -w -p /var/log/ -p data.csv -f -n email

# Mode interactif
mindctl -i

# Corrélation croisée système + données
mindctl -a insight -p /var/log/ -p metrics.csv

# Afficher l'aide
mindctl -h
```

---

## 🧪 Scénarios de test

### Scénario 1 — Léger (subshell)
```bash
mindctl -a cleaner -p data_100.csv -s
# 1 fichier CSV, 100 lignes
# Temps attendu : ~2 secondes
```

### Scénario 2 — Moyen (fork)
```bash
mindctl -a analyzer -p /data/medium/ -f
# 10 fichiers mixtes logs + CSV
# Temps attendu : ~5 secondes
```

### Scénario 3 — Lourd (threads + pipeline complet)
```bash
mindctl -w -p /var/log/ -p /data/large/ -t -n email
# 50 fichiers système + données
# Corrélation IA croisée
# Rapport envoyé par email
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
│   ├── systeme/
│   │   ├── summarizer.sh         ← Résume les logs Linux
│   │   ├── classifier.sh         ← Classe les erreurs par gravité
│   │   ├── monitor.sh            ← Surveille CPU/RAM/disque
│   │   └── coder.sh              ← Analyse les scripts
│   │
│   └── donnees/
│       ├── cleaner.sh            ← Supprime doublons et nulls
│       ├── transformer.sh        ← Convertit CSV ↔ JSON
│       ├── analyzer.sh           ← Statistiques et anomalies
│       ├── validator.sh          ← Vérifie la structure
│       └── insight.sh            ← Corrélation croisée IA
│
├── notifiers/
│   └── email.sh                  ← Envoi rapport par email
│
├── interactive/
│   └── chat.sh                   ← Mode interactif (-i)
│
├── fork_agent.c                  ← Gestion fork() en C
├── thread_agent.c                ← Gestion pthreads en C
│
├── exemple/
│   ├── test_leger.csv            ← 100 lignes pour scénario léger
│   ├── test_moyen/               ← 10 fichiers pour scénario moyen
│   └── test_lourd/               ← 50 fichiers pour scénario lourd
│
├── mindctl.conf                  ← Fichier de configuration
└── README.md                     ← Ce fichier
```

---

## 👥 Équipe

> Projet réalisé dans le cadre du module **Théorie des Systèmes d'Exploitation & SE Windows/Unix/Linux**
> ENSET Mohammedia — Université Hassan II de Casablanca — 2026

| Membre | Rôle |
|--------|------|
| 👤 Membre 1 | Script principal + gestion des options |
| 👤 Membre 2 | Agents IA + intégration LLM |
| 👤 Membre 3 | Modules C (fork + threads) + mode interactif |
| 👤 Membre 4 | Notifications email + documentation + tests |

---

<div align="center">

**Date limite de soumission : 14/05/2026 à 23:59:59**

---

*ENSET Mohammedia © 2026 — Tous droits réservés*

</div>
