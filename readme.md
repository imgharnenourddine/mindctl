<div align="center">

```
███████╗██╗   ██╗███████╗███╗   ███╗██╗███╗   ██╗██████╗
██╔════╝╚██╗ ██╔╝██╔════╝████╗ ████║██║████╗  ██║██╔══██╗
███████╗ ╚████╔╝ ███████╗██╔████╔██║██║██╔██╗ ██║██║  ██║
╚════██║  ╚██╔╝  ╚════██║██║╚██╔╝██║██║██║╚██╗██║██║  ██║
███████║   ██║   ███████║██║ ╚═╝ ██║██║██║ ╚████║██████╔╝
╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝
```

**Orchestrateur d'Agents IA pour Linux**

[![Bash](https://img.shields.io/badge/Bash-5.0+-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![C](https://img.shields.io/badge/C-99-A8B9CC?style=for-the-badge&logo=c&logoColor=white)](https://en.wikipedia.org/wiki/C99)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![LLM](https://img.shields.io/badge/LLM-Ollama%2FMistral-7C3AED?style=for-the-badge&logo=ollama&logoColor=white)](https://ollama.ai/)
[![License](https://img.shields.io/badge/Licence-ENSET%202026-0EA5E9?style=for-the-badge)](.)

<br/>

> 🤖 **sysmind** est un orchestrateur d'agents IA en Bash qui analyse automatiquement vos logs système, surveille vos ressources, et vous envoie des rapports intelligents — le tout en ligne de commande Linux.

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
- [📁 Ce que sysmind exploite](#-ce-que-sysmind-exploite)
- [🛡️ Gestion des erreurs](#️-gestion-des-erreurs)
- [📊 Journalisation](#-journalisation)
- [✅ Conformité aux exigences du prof](#-conformité-aux-exigences-du-prof)
- [🚀 Installation et utilisation](#-installation-et-utilisation)
- [🧪 Scénarios de test](#-scénarios-de-test)
- [📦 Structure du projet](#-structure-du-projet)
- [👥 Équipe](#-équipe)

---

## 🎯 Présentation du projet

**sysmind** (*System Mind*) est un outil en ligne de commande Linux développé en Bash et C, qui orchestre plusieurs **agents IA spécialisés** pour analyser automatiquement votre système Linux.

Chaque agent est un programme autonome qui :
1. **Collecte** des données depuis le système (logs, métriques, fichiers de config)
2. **Envoie** ces données à un LLM local (Ollama / Mistral) via `curl`
3. **Retourne** une analyse intelligente et des recommandations concrètes

```
sysmind [options] -p <fichier_ou_dossier>
```

---

## 💡 Idée et contexte

### Le problème

Un administrateur système reçoit chaque jour :
- Des **centaines de lignes de logs** illisibles
- Des **alertes de serveur** incompréhensibles
- Des **fichiers de configuration** complexes à vérifier

Sans outil adapté, il passe des heures à lire, filtrer et comprendre manuellement.

### La solution : sysmind

```
Sans sysmind                    Avec sysmind
─────────────────               ─────────────────────────────
Lire 500 lignes de logs  ──→    sysmind -a summarizer -p /var/log/syslog
Comprendre les erreurs   ──→    [agent] 3 erreurs critiques détectées :
Chercher des solutions   ──→           → Disk I/O error sur /dev/sda
Écrire un rapport        ──→           → SSH brute-force depuis 192.168.1.45
Durée : 2 heures         ──→    Durée : 8 secondes ✅
```

### Pourquoi c'est innovant ?

- 🧠 **Agentic AI** : thème numéro 1 mondial en 2026
- 🐧 **100% Linux natif** : aucune dépendance externe lourde
- 🔗 **Pipeline multi-agents** : les agents se chaînent automatiquement
- 💬 **Mode interactif** : chat en temps réel avec l'agent dans le terminal
- 📧 **Notifications email** : rapport envoyé automatiquement après chaque analyse

---

## 🤖 Les agents disponibles

| Agent | Rôle | Commande exemple |
|-------|------|-----------------|
| 🔍 `summarizer` | Résume et explique un fichier log | `sysmind -a summarizer -p /var/log/syslog` |
| 🗂️ `classifier` | Classe les erreurs par catégorie et gravité | `sysmind -a classifier -p /var/log/auth.log` |
| 📊 `monitor` | Analyse CPU, RAM, disque, réseau en temps réel | `sysmind -a monitor` |
| 💻 `coder` | Analyse un script Bash ou fichier C et détecte les bugs | `sysmind -a coder -p monscript.sh` |

---

## ⚙️ Options et fonctionnalités

```
SYNOPSIS
    sysmind [OPTIONS] -p <paramètre>

OPTIONS OBLIGATOIRES
    -p <chemin>       Fichier, dossier ou texte à analyser (OBLIGATOIRE)

OPTIONS PRINCIPALES
    -h                Affiche cette aide détaillée
    -f                Exécution via fork()    — processus fils isolé (C)
    -t                Exécution via threads   — parallélisme pthreads (C)
    -s                Exécution via subshell  — environnement isolé Bash
    -l <dossier>      Dossier de stockage des logs (défaut: /var/log/sysmind)
    -r                Réinitialise la configuration (administrateur requis)

OPTIONS AVANCÉES
    -a <agent>        Choisit l'agent : summarizer | classifier | monitor | coder
    -w                Mode pipeline : chaîne plusieurs agents automatiquement
    -i                Mode interactif : chat en temps réel avec l'agent
    -n email          Envoie le rapport par email après l'analyse
```

---

## 🔀 Modes d'exécution

sysmind propose **3 modes d'exécution** correspondant aux options `-s`, `-f` et `-t` :

### 🔵 `-s` Subshell — Isolation Bash

Le rapport final s'exécute dans un sous-shell Bash isolé. Si le déploiement échoue, le script principal continue sans être affecté.

```bash
sysmind -a summarizer -p /var/log/syslog -s
```

```
Shell principal
    └── (sous-shell) → génère le rapport → ferme proprement
```

**Quand l'utiliser :** traitements légers, 1 seul fichier à analyser.

---

### 🟡 `-f` Fork — Isolation par processus (C)

Chaque agent est lancé dans un **processus fils indépendant** via `fork()`. Si un agent plante (timeout LLM, erreur réseau), les autres continuent.

```bash
sysmind -a classifier -p /var/log/ -f
```

```
Processus père (sysmind)
    ├── fork() → Agent 1 (syslog)   → analyse → résultat
    ├── fork() → Agent 2 (auth.log) → analyse → résultat
    └── fork() → Agent 3 (kern.log) → analyse → résultat
```

**Quand l'utiliser :** traitements moyens, plusieurs fichiers à analyser en parallèle.

---

### 🔴 `-t` Threads — Parallélisme maximal (C + pthreads)

Plusieurs fichiers sont analysés **simultanément** dans le même processus via `pthreads`. Plus léger que fork, idéal pour de grandes quantités de fichiers.

```bash
sysmind -a summarizer -p /var/log/ -t
```

```
Processus unique (sysmind)
    ├── Thread 1 → syslog     ──→ analyse LLM
    ├── Thread 2 → auth.log   ──→ analyse LLM
    ├── Thread 3 → kern.log   ──→ analyse LLM
    └── Thread 4 → dpkg.log   ──→ analyse LLM
                               (tous simultanément)
```

**Quand l'utiliser :** traitements lourds, 10 à 50 fichiers à analyser.

---

### Comparaison des performances

| Mode | Fichiers | Temps estimé | Ressources |
|------|----------|-------------|------------|
| `-s` Subshell | 1 fichier | ~3s | Légères |
| `-f` Fork | 5-10 fichiers | ~5s | Moyennes |
| `-t` Threads | 50 fichiers | ~8s | Optimisées |
| Sans parallélisme | 50 fichiers | ~150s | — |

---

## 💬 Mode interactif

Le mode interactif `-i` permet de **discuter directement** avec l'agent IA dans le terminal. L'agent se souvient du contexte de la conversation.

```bash
sysmind -i
```

```
╔══════════════════════════════════════════════════╗
║          sysmind — Mode Interactif v1.0          ║
║          Tapez 'help' pour les commandes         ║
╚══════════════════════════════════════════════════╝

[agent] Bonjour ! Je surveille votre système. Que voulez-vous analyser ?

[vous]  analyse les erreurs dans /var/log/syslog

[agent] Lecture du fichier...
        Envoi au LLM pour analyse...

        Résultat :
        → 3 erreurs critiques détectées
        → Disk I/O error à 09:15 sur /dev/sda
        → SSH failed login x5 depuis 192.168.1.45
        → Memory pressure à 09:45 (94% utilisé)

[vous]  c'est grave le disk I/O error ?

[agent] Oui, potentiellement grave.
        /dev/sda montre des signes de défaillance physique.
        Recommandation : exécutez 'smartctl -a /dev/sda'
        et planifiez une sauvegarde immédiate.

[vous]  envoie le rapport par email

[agent] Rapport envoyé à admin@example.com ✅

[vous]  exit
[agent] Session terminée. Rapport sauvegardé → /var/log/sysmind/history.log
```

### Commandes disponibles en mode interactif

| Commande | Action |
|----------|--------|
| `analyse <fichier>` | Lance l'agent summarizer sur ce fichier |
| `monitore` | Affiche CPU/RAM/Disque en direct |
| `rapport` | Génère et envoie le rapport par email |
| `historique` | Affiche les 10 derniers échanges |
| `reset` | Efface la mémoire de la conversation |
| `help` | Affiche toutes les commandes disponibles |
| `exit` | Quitte le mode interactif |

> 💡 En mode interactif, les tâches lourdes sont automatiquement lancées en **fork** pour ne pas bloquer le chat.

---

## 📧 Notifications email

Avec l'option `-n email`, sysmind envoie automatiquement le rapport par email après chaque analyse.

```bash
sysmind -a monitor -n email
```

Le rapport reçu par email ressemble à ceci :

```
De      : sysmind@votreserveur.com
À       : admin@example.com
Sujet   : [sysmind] Rapport — 2026-04-17 10:30:00

Agent     : monitor
Statut    : SUCCÈS ✅

Résultat IA :
→ CPU : 45% (normal)
→ RAM : 6.2 GB / 8 GB (78% — attention)
→ Disque /dev/sda : 89% utilisé — CRITIQUE
→ Recommandation : libérer de l'espace sur /dev/sda immédiatement

Logs complets : /var/log/sysmind/history.log
```

### Configuration email (`/etc/sysmind/sysmind.conf`)

```bash
# Configuration sysmind
NOTIFY_EMAIL="admin@example.com"
SMTP_SERVER="smtp.gmail.com"
LLM_MODEL="mistral"
LLM_URL="http://localhost:11434/api/generate"
LOG_DIR="/var/log/sysmind"
```

---

## 📁 Ce que sysmind exploite

sysmind peut analyser plusieurs types de données système :

```
sysmind exploite
    ├── 📄 Logs système        /var/log/syslog, auth.log, kern.log...
    ├── 📊 Métriques système   CPU (top), RAM (free), Disque (df), Réseau (netstat)
    ├── ⚙️  Fichiers de config  /etc/ssh/sshd_config, /etc/fstab, /etc/hosts...
    ├── 📜 Historique shell    ~/.bash_history
    ├── 💻 Code source         Scripts .sh, fichiers .c, .py
    └── ✍️  Saisie directe     Questions libres en mode interactif -i
```

Sous Linux, **tout est du texte** — et le LLM excelle à analyser du texte sous n'importe quelle forme.

---

## 🛡️ Gestion des erreurs

Chaque erreur produit un **code spécifique** et affiche automatiquement l'aide `-h` :

| Code | Erreur | Exemple |
|------|--------|---------|
| `100` | Option inexistante | `sysmind -z` |
| `101` | Paramètre `-p` manquant | `sysmind -a summarizer` |
| `102` | LLM inaccessible (Ollama non démarré) | — |
| `103` | Fichier ou dossier introuvable | `sysmind -p /inexistant` |
| `104` | Permission refusée (option `-r` sans root) | — |
| `105` | Agent inconnu | `sysmind -a inconnu` |

```bash
$ sysmind -a summarizer
[ERREUR 101] Paramètre obligatoire manquant : -p <fichier>

UTILISATION : sysmind [options] -p <paramètre>
...
```

---

## 📊 Journalisation

Toutes les sorties (normales et erreurs) sont redirigées **simultanément** vers le terminal et vers le fichier de log `/var/log/sysmind/history.log`.

### Format du fichier de log

```
yyyy-mm-dd-hh-mm-ss : username : INFOS : message
yyyy-mm-dd-hh-mm-ss : username : ERROR : message d'erreur
```

### Exemple réel

```
2026-04-17-10-30-00 : root : INFOS : Agent summarizer démarré
2026-04-17-10-30-01 : root : INFOS : Fichier /var/log/syslog lu (1247 lignes)
2026-04-17-10-30-02 : root : INFOS : Envoi au LLM Mistral...
2026-04-17-10-30-04 : root : INFOS : Réponse LLM reçue en 1.8s
2026-04-17-10-30-04 : root : INFOS : Rapport généré avec succès
2026-04-17-10-30-05 : root : INFOS : Email envoyé à admin@example.com
2026-04-17-10-30-05 : root : ERROR : Thread 3 timeout après 30s
```

### Rapports individuels

Chaque analyse génère aussi son propre fichier rapport :

```
/var/log/sysmind/reports/
├── report_2026-04-17-10-30-00_syslog.txt
├── report_2026-04-17-11-00-00_auth.txt
└── report_2026-04-17-12-00-00_monitor.txt
```

---

## ✅ Conformité aux exigences du prof

Voici comment **sysmind** répond à chaque directive du projet :

### 3.2.1 — Besoin réel et original ✅
Automatisation de l'analyse de logs système via agents IA — besoin quotidien réel de tout administrateur système.

### 3.2.2 — 6 options obligatoires ✅
`-h` `-f` `-t` `-s` `-l` `-r` + options avancées `-a` `-p` `-w` `-i` `-n`

### 3.2.2 — Paramètre obligatoire ✅
`-p <chemin>` est obligatoire. Son absence déclenche l'erreur `101`.

### 3.2.2 — Commandes Unix/Linux ✅
`curl`, `grep`, `awk`, `sed`, `tee`, `find`, `top`, `free`, `df`, `netstat`, `inotifywait`, `mail`

### 3.2.2 — Concepts shell ✅

| Concept | Utilisation dans sysmind |
|---------|--------------------------|
| Conditions | Vérifier si Ollama tourne, si fichier existe, si root |
| Boucles | Parcourir tous les fichiers d'un dossier de logs |
| Fonctions | `launch_agent()`, `log_message()`, `check_root()`, `send_email()` |
| Variables d'environnement | `SYSMIND_MODEL`, `SYSMIND_LOG_DIR`, `SYSMIND_EMAIL` |
| Expressions régulières | Filtrer lignes ERROR/WARNING dans les logs |
| Pipes et filtres | `cat log \| grep ERROR \| awk '{print $5}' \| curl ...` |
| Contrôle d'accès | Option `-r` réservée à root via `[[ $EUID -ne 0 ]]` |
| Archivage/compression | Archivage automatique des anciens rapports avec `tar` |

### 3.2.2 — Fork / Thread / Subshell ✅
Trois modes justifiés logiquement, implémentés en C (`fork_agent.c`, `thread_agent.c`) et Bash.

### 3.2.2 — Journalisation ✅
`/var/log/sysmind/history.log` avec format `yyyy-mm-dd-hh-mm-ss : username : TYPE : message`

### 3.2.3 — Gestion d'erreurs ✅
5 codes d'erreur spécifiques + affichage automatique de l'aide après chaque erreur.

### 3.2.4 — 3 scénarios de test ✅

| Scénario | Description | Mode |
|----------|-------------|------|
| 🟢 Léger | 1 fichier log → agent summarizer | `-s` subshell |
| 🟡 Moyen | 10 fichiers → 3 agents en parallèle | `-t` threads |
| 🔴 Lourd | Pipeline complet sur 50 fichiers | `-f` fork + `-w` |

### 3.2.5 — Documentation ✅
Version simplifiée accessible via `-h`. Version complète dans le PDF avec captures d'écran.

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

### Installation de sysmind

```bash
git clone https://github.com/votre-equipe/sysmind.git
cd sysmind
chmod +x sysmind.sh
sudo cp sysmind.sh /usr/local/bin/sysmind

# Compiler les modules C
gcc fork_agent.c -o fork_agent
gcc thread_agent.c -o thread_agent -lpthread

# Créer le dossier de logs
sudo mkdir -p /var/log/sysmind/reports
```

### Exemples d'utilisation

```bash
# Analyser un fichier log (subshell)
sysmind -a summarizer -p /var/log/syslog -s

# Analyser un dossier entier en parallèle (threads)
sysmind -a classifier -p /var/log/ -t

# Pipeline complet avec notification email (fork)
sysmind -w -p /var/log/ -f -n email

# Mode interactif (chat avec l'agent)
sysmind -i

# Surveiller les ressources système
sysmind -a monitor

# Afficher l'aide
sysmind -h
```

---

## 🧪 Scénarios de test

### Scénario 1 — Léger (subshell)
```bash
sysmind -a summarizer -p /var/log/syslog -s
# 1 fichier, 1 agent, sous-shell isolé
# Temps attendu : ~3 secondes
```

### Scénario 2 — Moyen (threads)
```bash
sysmind -a classifier -p /var/log/ -t
# 10 fichiers, analyse en parallèle via threads
# Temps attendu : ~8 secondes
```

### Scénario 3 — Lourd (fork + pipeline)
```bash
sysmind -w -p /var/log/ -f -n email
# 50 fichiers, pipeline 3 agents chaînés via fork
# Rapport envoyé par email à la fin
# Temps attendu : ~15 secondes
```

---

## 📦 Structure du projet

```
sysmind/
│
├── sysmind.sh                  ← Script principal (chef d'orchestre)
│
├── agents/
│   ├── summarizer.sh           ← Résume et explique les logs
│   ├── classifier.sh           ← Classe les erreurs par catégorie
│   ├── monitor.sh              ← Analyse les ressources système
│   └── coder.sh                ← Analyse du code source
│
├── notifiers/
│   └── email.sh                ← Envoi du rapport par email
│
├── interactive/
│   └── chat.sh                 ← Mode interactif (-i)
│
├── fork_agent.c                ← Gestion fork() en C
├── thread_agent.c              ← Gestion pthreads en C
│
├── exemple/
│   ├── test_leger.log          ← Log pour scénario léger
│   ├── test_moyen/             ← 10 logs pour scénario moyen
│   └── test_lourd/             ← 50 logs pour scénario lourd
│
├── sysmind.conf                ← Fichier de configuration
└── README.md                   ← Ce fichier
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