#!/bin/bash

source ~/mindctl/mindctl.conf
source ~/mindctl/core/logger.sh
source ~/mindctl/core/errors.sh
source ~/mindctl/core/llm.sh

PROJET="$1"
LOCKFILE="$PROJET/depguard.lock"
CONTEXT_FILE="/tmp/mindctl_context.env"

# ══════════════════════════════════════════════════════════
# POINT D'ENTRÉE — Vérifier lockfile
# ══════════════════════════════════════════════════════════

function verifier_lockfile() {
    if [ -f "$LOCKFILE" ]; then
        log_message "INFOS" "Lockfile détecté → $LOCKFILE"
        echo ""
        echo "[depguard] Lockfile existant détecté."
        echo ""
        echo "  1) Restaurer l'état du lockfile"
        echo "  2) Re-analyser le projet"
        echo "  3) Ignorer et quitter"
        echo ""
        read -p "Votre choix (1/2/3) : " CHOIX

        case $CHOIX in
            1) restaurer_lockfile ;;
            2) analyser_projet ;;
            3) exit 0 ;;
            *) erreur 100 ;;
        esac
    else
        log_message "INFOS" "Aucun lockfile → analyse complète"
        analyser_projet
    fi
}

# ══════════════════════════════════════════════════════════
# RESTAURER LE LOCKFILE
# ══════════════════════════════════════════════════════════

function restaurer_lockfile() {
    log_message "INFOS" "Restauration depuis lockfile"
    echo ""
    echo "[depguard] Restauration de l'état validé..."
    echo ""

    # Lire le lockfile et réinstaller les dépendances
    echo "[depguard] Réinstallation des dépendances depuis le lockfile..."

    # Restaurer requirements.txt
    if grep -q "\[dependances_python\]" "$LOCKFILE"; then
        echo ""
        echo "[depguard] Restauration dépendances Python..."
        LIBS=$(sed -n '/\[dependances_python\]/,/\[/p' "$LOCKFILE" | \
               grep -v '^\[' | grep -v '^$')
        echo "$LIBS" > /tmp/requirements_lock.txt
        pip3 install -r /tmp/requirements_lock.txt 2>&1 | tail -3
        log_message "INFOS" "Dépendances Python restaurées"
    fi

    # Restaurer package.json
    if grep -q "\[dependances_node\]" "$LOCKFILE" && \
       [ -f "$PROJET/package.json" ]; then
        echo ""
        echo "[depguard] Restauration dépendances Node..."
        cd "$PROJET" && npm install 2>&1 | tail -3
        cd - > /dev/null
        log_message "INFOS" "Dépendances Node restaurées"
    fi

    # Restaurer pom.xml
    if grep -q "\[dependances_java\]" "$LOCKFILE" && \
       [ -f "$PROJET/pom.xml" ]; then
        echo ""
        echo "[depguard] Restauration dépendances Java..."
        cd "$PROJET" && mvn install -q 2>&1 | tail -3
        cd - > /dev/null
        log_message "INFOS" "Dépendances Java restaurées"
    fi

    # Restaurer composer.json
    if grep -q "\[dependances_php\]" "$LOCKFILE" && \
       [ -f "$PROJET/composer.json" ]; then
        echo ""
        echo "[depguard] Restauration dépendances PHP..."
        cd "$PROJET" && composer install 2>&1 | tail -3
        cd - > /dev/null
        log_message "INFOS" "Dépendances PHP restaurées"
    fi

    echo ""
    echo "[depguard] Restauration terminée ✅"
    log_message "INFOS" "Restauration terminée"

    # Passer directement à étape 2 et 3
    etape2_systeme
    etape3_lancement
}

# ══════════════════════════════════════════════════════════
# ÉTAPE 1 — DÉTECTER ET CORRIGER LES CONFLITS
# ══════════════════════════════════════════════════════════

function etape1_conflits() {
    log_message "INFOS" "Étape 1 — Détection des conflits"
    echo ""
    echo "[depguard] ── Étape 1 : Analyse des fichiers de configuration ──"

    # Collecter tous les fichiers de config
    FICHIERS=$(find "$PROJET" -maxdepth 2 -type f \( \
        -name "Dockerfile" \
        -o -name "docker-compose.yml" \
        -o -name "package.json" \
        -o -name "requirements.txt" \
        -o -name ".env" \
        -o -name "pom.xml" \
        -o -name "nginx.conf" \
        -o -name "composer.json" \
        -o -name "go.mod" \
    \))

    if [ -z "$FICHIERS" ]; then
        log_message "ERROR" "Aucun fichier de configuration trouvé"
        erreur 102
    fi

    # Construire le contenu de tous les fichiers
    CONTENU=""
    for FICHIER in $FICHIERS; do
        CONTENU="$CONTENU\n=== $FICHIER ===\n$(cat $FICHIER)\n"
        log_message "INFOS" "Fichier lu : $FICHIER"
    done

    # Envoyer au LLM pour analyse
    PROMPT="Voici les fichiers de configuration d'un projet DevOps :
$CONTENU

Analyse ces fichiers et trouve TOUTES les incohérences.
Pour chaque incohérence donne EXACTEMENT ce format :
NIVEAU: CRITIQUE ou WARNING
DESCRIPTION: explication courte
FICHIER: nom du fichier à modifier
LIGNE_AVANT: la ligne exacte actuelle
LIGNE_APRES: la ligne exacte corrigée
---
Réponds en français."

    echo "[depguard] Envoi au LLM pour analyse..."
    CONFLITS=$(appeler_llm "$PROMPT")

    echo ""
    echo "[depguard] Conflits détectés :"
    echo "─────────────────────────────────"
    echo "$CONFLITS"
    echo "─────────────────────────────────"

    echo "$CONFLITS" > /var/log/mindctl/reports/last_depguard.txt
    log_message "INFOS" "Conflits sauvegardés"

    # Proposer correction automatique
    echo ""
    read -p "[depguard] Corriger automatiquement ? (o/n) : " CHOIX
    [ "$CHOIX" = "o" ] && corriger_conflits "$CONFLITS"

    log_message "INFOS" "Étape 1 terminée"
}

# ── Corriger les conflits ─────────────────────────────────
function corriger_conflits() {
    local CONFLITS="$1"
    log_message "INFOS" "Correction automatique des conflits"

    FICHIER_A_CORRIGER=""
    LIGNE_AVANT=""
    LIGNE_APRES=""

    while IFS= read -r LIGNE; do
        case "$LIGNE" in
            FICHIER:*)
                FICHIER_A_CORRIGER=$(echo "$LIGNE" | cut -d: -f2- | xargs)
                FICHIER_A_CORRIGER="$PROJET/$FICHIER_A_CORRIGER"
                ;;
            LIGNE_AVANT:*)
                LIGNE_AVANT=$(echo "$LIGNE" | cut -d: -f2- | xargs)
                ;;
            LIGNE_APRES:*)
                LIGNE_APRES=$(echo "$LIGNE" | cut -d: -f2- | xargs)
                ;;
            ---)
                if [ -n "$FICHIER_A_CORRIGER" ] && \
                   [ -n "$LIGNE_AVANT" ] && \
                   [ -n "$LIGNE_APRES" ] && \
                   [ -f "$FICHIER_A_CORRIGER" ]; then

                    cp "$FICHIER_A_CORRIGER" "${FICHIER_A_CORRIGER}.backup"
                    sed -i "s|$LIGNE_AVANT|$LIGNE_APRES|g" "$FICHIER_A_CORRIGER"

                    echo "  ✅ Corrigé : $FICHIER_A_CORRIGER"
                    echo "     Avant  : $LIGNE_AVANT"
                    echo "     Après  : $LIGNE_APRES"
                    log_message "INFOS" "Corrigé : $FICHIER_A_CORRIGER"

                    FICHIER_A_CORRIGER=""
                    LIGNE_AVANT=""
                    LIGNE_APRES=""
                fi
                ;;
        esac
    done <<< "$CONFLITS"

    echo ""
    echo "[depguard] Corrections appliquées ✅"
    echo "[depguard] Sauvegardes créées avec extension .backup"
}

# ══════════════════════════════════════════════════════════
# ÉTAPE 2 — VÉRIFIER LE SYSTÈME ET INSTALLER LES DÉPENDANCES
# ══════════════════════════════════════════════════════════

function etape2_systeme() {
    log_message "INFOS" "Étape 2 — Vérification du système Linux"
    echo ""
    echo "[depguard] ── Étape 2 : Vérification du système ──"

    PROBLEMES=""

    # ── Détecter ce que le projet utilise ────────────────
    NEED_NODE=false;   NODE_REQUIS=""
    NEED_PYTHON=false; PYTHON_REQUIS=""
    NEED_JAVA=false;   JAVA_REQUIS=""
    NEED_PHP=false
    NEED_GO=false
    NEED_DOCKER=false
    NEED_POSTGRES=false
    NEED_MYSQL=false
    NEED_REDIS=false

    [ -f "$PROJET/Dockerfile" ] && {
        NODE_REQUIS=$(grep -oP '(?<=node:)\d+' "$PROJET/Dockerfile" | head -1)
        PYTHON_REQUIS=$(grep -oP '(?<=python:)\d+\.\d+' "$PROJET/Dockerfile" | head -1)
        JAVA_REQUIS=$(grep -oP '(?<=openjdk:)\d+' "$PROJET/Dockerfile" | head -1)
        [ -n "$NODE_REQUIS" ]   && NEED_NODE=true
        [ -n "$PYTHON_REQUIS" ] && NEED_PYTHON=true
        [ -n "$JAVA_REQUIS" ]   && NEED_JAVA=true
        NEED_DOCKER=true
    }

    [ -f "$PROJET/package.json" ]    && NEED_NODE=true
    [ -f "$PROJET/requirements.txt" ] && NEED_PYTHON=true
    [ -f "$PROJET/pom.xml" ]         && NEED_JAVA=true
    [ -f "$PROJET/composer.json" ]   && NEED_PHP=true
    [ -f "$PROJET/go.mod" ]          && NEED_GO=true

    [ -f "$PROJET/docker-compose.yml" ] && {
        NEED_DOCKER=true
        grep -qi "postgres" "$PROJET/docker-compose.yml" && NEED_POSTGRES=true
        grep -qi "mysql"    "$PROJET/docker-compose.yml" && NEED_MYSQL=true
        grep -qi "redis"    "$PROJET/docker-compose.yml" && NEED_REDIS=true
    }

    # ── Fonction d'installation automatique ──────────────
    function proposer_installation() {
        local OUTIL="$1"
        local PAQUET="$2"
        echo ""
        read -p "  [depguard] Installer $OUTIL automatiquement ? (o/n) : " REP
        if [ "$REP" = "o" ]; then
            sudo apt install -y "$PAQUET" 2>&1 | tail -1
            command -v $OUTIL &>/dev/null && {
                echo "  ✅ $OUTIL installé avec succès"
                log_message "INFOS" "$OUTIL installé automatiquement"
            } || {
                echo "  ❌ Échec installation $OUTIL"
                log_message "ERROR" "Échec installation $OUTIL"
                PROBLEMES="$PROBLEMES $OUTIL"
            }
        else
            echo "  ⚠️  $OUTIL ignoré — installez-le manuellement"
            PROBLEMES="$PROBLEMES $OUTIL"
            log_message "ERROR" "$OUTIL ignoré par l'utilisateur"
        fi
    }

    # ── Vérifier Node.js ─────────────────────────────────
    if [ "$NEED_NODE" = true ]; then
        echo ""
        echo "[depguard] Vérification Node.js..."
        if command -v node &>/dev/null; then
            NODE_V=$(node --version | tr -d 'v' | cut -d. -f1)
            if [ -n "$NODE_REQUIS" ] && [ "$NODE_V" -lt "$NODE_REQUIS" ]; then
                echo "  ❌ node v$NODE_V — requis v$NODE_REQUIS"
                log_message "ERROR" "node trop vieux : v$NODE_V < v$NODE_REQUIS"
                PROBLEMES="$PROBLEMES node_version"
                read -p "  [depguard] Mettre à jour node v$NODE_REQUIS ? (o/n) : " REP
                if [ "$REP" = "o" ]; then
                    curl -fsSL https://deb.nodesource.com/setup_${NODE_REQUIS}.x \
                        | sudo -E bash -
                    sudo apt install -y nodejs
                    echo "  ✅ node mis à jour vers v$NODE_REQUIS"
                    log_message "INFOS" "node mis à jour vers v$NODE_REQUIS"
                fi
            else
                echo "  ✅ node v$NODE_V"
                log_message "INFOS" "node OK : v$NODE_V"
            fi

            # Installer les dépendances npm
            if [ -f "$PROJET/package.json" ]; then
                echo ""
                echo "[depguard] Installation des dépendances npm..."
                cd "$PROJET" && npm install 2>&1 | tail -3
                cd - > /dev/null
                log_message "INFOS" "npm install terminé"
            fi
        else
            echo "  ❌ node non installé"
            log_message "ERROR" "node non installé"
            proposer_installation "node" "nodejs"
        fi
    fi

    # ── Vérifier Python ───────────────────────────────────
    if [ "$NEED_PYTHON" = true ]; then
        echo ""
        echo "[depguard] Vérification Python..."
        if command -v python3 &>/dev/null; then
            PY_V=$(python3 --version | cut -d' ' -f2)
            echo "  ✅ python3 v$PY_V"
            log_message "INFOS" "python3 OK : v$PY_V"

            # Vérifier pip
            if ! command -v pip3 &>/dev/null; then
                echo "  ❌ pip3 non installé"
                proposer_installation "pip3" "python3-pip"
            else
                echo "  ✅ pip3 installé"
            fi

            # Installer les dépendances requirements.txt
            if [ -f "$PROJET/requirements.txt" ]; then
                echo ""
                echo "[depguard] Installation des dépendances Python..."
                pip3 install -r "$PROJET/requirements.txt" 2>&1 | tail -3
                log_message "INFOS" "pip install terminé"
            fi
        else
            echo "  ❌ python3 non installé"
            log_message "ERROR" "python3 non installé"
            proposer_installation "python3" "python3"
        fi
    fi

    # ── Vérifier Java ─────────────────────────────────────
    if [ "$NEED_JAVA" = true ]; then
        echo ""
        echo "[depguard] Vérification Java..."
        if command -v java &>/dev/null; then
            JAVA_V=$(java -version 2>&1 | grep -oP '(?<=version ")\d+')
            if [ -n "$JAVA_REQUIS" ] && [ "$JAVA_V" -lt "$JAVA_REQUIS" ]; then
                echo "  ❌ java v$JAVA_V — requis v$JAVA_REQUIS"
                PROBLEMES="$PROBLEMES java_version"
                proposer_installation "java" "openjdk-${JAVA_REQUIS}-jdk"
            else
                echo "  ✅ java v$JAVA_V"
                log_message "INFOS" "java OK : v$JAVA_V"
            fi

            # Installer les dépendances Maven
            if [ -f "$PROJET/pom.xml" ]; then
                if command -v mvn &>/dev/null; then
                    echo ""
                    echo "[depguard] Installation des dépendances Maven..."
                    cd "$PROJET" && mvn install -q 2>&1 | tail -3
                    cd - > /dev/null
                    log_message "INFOS" "mvn install terminé"
                else
                    echo "  ❌ maven non installé"
                    proposer_installation "mvn" "maven"
                fi
            fi
        else
            echo "  ❌ java non installé"
            log_message "ERROR" "java non installé"
            proposer_installation "java" "default-jdk"
        fi
    fi

    # ── Vérifier PHP ──────────────────────────────────────
    if [ "$NEED_PHP" = true ]; then
        echo ""
        echo "[depguard] Vérification PHP..."
        if command -v php &>/dev/null; then
            PHP_V=$(php --version | head -1 | cut -d' ' -f2)
            echo "  ✅ php v$PHP_V"
            log_message "INFOS" "php OK : v$PHP_V"

            # Installer les dépendances composer
            if [ -f "$PROJET/composer.json" ]; then
                if command -v composer &>/dev/null; then
                    echo ""
                    echo "[depguard] Installation des dépendances Composer..."
                    cd "$PROJET" && composer install 2>&1 | tail -3
                    cd - > /dev/null
                    log_message "INFOS" "composer install terminé"
                else
                    echo "  ❌ composer non installé"
                    proposer_installation "composer" "composer"
                fi
            fi
        else
            echo "  ❌ php non installé"
            proposer_installation "php" "php"
        fi
    fi

    # ── Vérifier Go ───────────────────────────────────────
    if [ "$NEED_GO" = true ]; then
        echo ""
        echo "[depguard] Vérification Go..."
        if command -v go &>/dev/null; then
            GO_V=$(go version | cut -d' ' -f3 | tr -d 'go')
            echo "  ✅ go v$GO_V"
            log_message "INFOS" "go OK : v$GO_V"

            # Installer les dépendances go
            if [ -f "$PROJET/go.mod" ]; then
                echo ""
                echo "[depguard] Installation des dépendances Go..."
                cd "$PROJET" && go mod download 2>&1 | tail -3
                cd - > /dev/null
                log_message "INFOS" "go mod download terminé"
            fi
        else
            echo "  ❌ go non installé"
            proposer_installation "go" "golang"
        fi
    fi

    # ── Vérifier Docker ───────────────────────────────────
    if [ "$NEED_DOCKER" = true ]; then
        echo ""
        echo "[depguard] Vérification Docker..."
        if command -v docker &>/dev/null; then
            DOCKER_V=$(docker --version | cut -d' ' -f3 | tr -d ',')
            echo "  ✅ docker v$DOCKER_V"
            log_message "INFOS" "docker OK : v$DOCKER_V"

            if ! command -v docker-compose &>/dev/null; then
                echo "  ❌ docker-compose non installé"
                proposer_installation "docker-compose" "docker-compose"
            else
                echo "  ✅ docker-compose installé"
            fi
        else
            echo "  ❌ docker non installé"
            proposer_installation "docker" "docker.io"
        fi
    fi

    # ── Vérifier clients base de données ─────────────────
    [ "$NEED_POSTGRES" = true ] && {
        echo ""
        echo "[depguard] Vérification PostgreSQL client..."
        command -v psql &>/dev/null && \
            echo "  ✅ postgresql-client installé" || \
            proposer_installation "psql" "postgresql-client"
    }

    [ "$NEED_MYSQL" = true ] && {
        echo ""
        echo "[depguard] Vérification MySQL client..."
        command -v mysql &>/dev/null && \
            echo "  ✅ mysql-client installé" || \
            proposer_installation "mysql" "mysql-client"
    }

    [ "$NEED_REDIS" = true ] && {
        echo ""
        echo "[depguard] Vérification Redis client..."
        command -v redis-cli &>/dev/null && \
            echo "  ✅ redis-cli installé" || \
            proposer_installation "redis-cli" "redis-tools"
    }

    # ── Vérifier les ports ────────────────────────────────
    echo ""
    echo "[depguard] Vérification des ports..."
    if [ -f "$PROJET/.env" ]; then
        PORTS=$(grep -oP '\w+=\d{4,5}' "$PROJET/.env" | grep -oP '\d{4,5}')
        for PORT in $PORTS; do
            if lsof -i :$PORT &>/dev/null; then
                PROCESS=$(lsof -i :$PORT | awk 'NR==2 {print $1}')
                echo "  ❌ Port $PORT occupé par $PROCESS"
                PROBLEMES="$PROBLEMES port:$PORT"
                log_message "ERROR" "Port $PORT occupé par $PROCESS"
            else
                echo "  ✅ Port $PORT libre"
                log_message "INFOS" "Port $PORT libre"
            fi
        done
    fi

    # ── Vérifier espace disque ────────────────────────────
    echo ""
    echo "[depguard] Vérification espace disque..."
    DISQUE_DISPO=$(df -h / | awk 'NR==2 {print $4}')
    DISQUE_POURCENT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    [ "$DISQUE_POURCENT" -gt 90 ] && {
        echo "  ❌ Disque critique : $DISQUE_DISPO ($DISQUE_POURCENT% utilisé)"
        PROBLEMES="$PROBLEMES disque_critique"
        log_message "ERROR" "Disque critique : $DISQUE_POURCENT%"
    } || {
        echo "  ✅ Disque : $DISQUE_DISPO ($DISQUE_POURCENT% utilisé)"
        log_message "INFOS" "Disque OK : $DISQUE_DISPO"
    }

    # ── Vérifier RAM ──────────────────────────────────────
    echo ""
    echo "[depguard] Vérification RAM..."
    RAM_DISPO=$(free -h | awk 'NR==2 {print $7}')
    RAM_TOTAL=$(free -h | awk 'NR==2 {print $2}')
    RAM_POURCENT=$(free | awk 'NR==2 {printf "%.0f", $3/$2*100}')

    [ "$RAM_POURCENT" -gt 90 ] && {
        echo "  ❌ RAM critique : $RAM_DISPO sur $RAM_TOTAL ($RAM_POURCENT% utilisé)"
        PROBLEMES="$PROBLEMES ram_critique"
        log_message "ERROR" "RAM critique : $RAM_POURCENT%"
    } || {
        echo "  ✅ RAM : $RAM_DISPO sur $RAM_TOTAL ($RAM_POURCENT% utilisé)"
        log_message "INFOS" "RAM OK : $RAM_DISPO"
    }

    # ── Résumé ────────────────────────────────────────────
    echo ""
    [ -n "$PROBLEMES" ] && {
        echo "[depguard] ⚠️  Problèmes restants : $PROBLEMES"
        log_message "ERROR" "Problèmes restants : $PROBLEMES"
    } || {
        echo "[depguard] Système compatible ✅"
        log_message "INFOS" "Système compatible"
    }

    log_message "INFOS" "Étape 2 terminée"
}

# ══════════════════════════════════════════════════════════
# ÉTAPE 3 — LANCER LE PROJET
# ══════════════════════════════════════════════════════════

function etape3_lancement() {
    log_message "INFOS" "Étape 3 — Lancement du projet"
    echo ""
    echo "[depguard] ── Étape 3 : Lancement du projet ──"

    if [ -f "$PROJET/docker-compose.yml" ]; then

        # Détecter les infos DB
        DB_TYPE=$(grep -i "image:" "$PROJET/docker-compose.yml" | \
                  grep -iE "postgres|mysql|mongo" | \
                  grep -oiE "postgres|mysql|mongo" | head -1)

        DB_PORT=$(grep -A10 "$DB_TYPE" "$PROJET/docker-compose.yml" \
                  2>/dev/null | grep -oP '\d+:\d+' | head -1 | cut -d: -f1)

        DB_USER=$(grep -iE "POSTGRES_USER|MYSQL_USER" \
                  "$PROJET/docker-compose.yml" | \
                  cut -d= -f2 | tr -d '"' | head -1)

        DB_PASS=$(grep -iE "POSTGRES_PASSWORD|MYSQL_PASSWORD" \
                  "$PROJET/docker-compose.yml" | \
                  cut -d= -f2 | tr -d '"' | head -1)

        DB_NAME=$(grep -iE "POSTGRES_DB|MYSQL_DATABASE" \
                  "$PROJET/docker-compose.yml" | \
                  cut -d= -f2 | tr -d '"' | head -1)

        # Écrire le contexte pour les agents données
        cat > "$CONTEXT_FILE" << EOF
DB_TYPE=$DB_TYPE
DB_PORT=$DB_PORT
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_NAME=$DB_NAME
PROJECT_STATUS=RUNNING
PROJECT_PATH=$PROJET
EOF
        log_message "INFOS" "Contexte DB transmis → $CONTEXT_FILE"
        echo "  ✅ Base détectée : $DB_TYPE sur port $DB_PORT"

        # Lancer docker-compose
        echo ""
        echo "[depguard] Lancement de docker-compose..."
        docker-compose -f "$PROJET/docker-compose.yml" up -d \
            2>&1 | tee /tmp/startup.log

        sleep 5

        # Vérifier que l'app répond
        APP_PORT=$(grep -oP '(?<=PORT=)\d+' "$PROJET/.env" 2>/dev/null | head -1)
        if [ -n "$APP_PORT" ]; then
            echo ""
            echo "[depguard] Vérification des services..."
            if curl -s -o /dev/null -w "%{http_code}" \
               http://localhost:$APP_PORT 2>/dev/null | \
               grep -qE "200|301|302"; then
                echo "  ✅ App répond sur port $APP_PORT"
                log_message "INFOS" "App opérationnelle sur port $APP_PORT"
            else
                echo "  ❌ App ne répond pas sur port $APP_PORT"
                log_message "ERROR" "App ne répond pas"
                diagnostiquer_echec
                return
            fi
        fi
    else
        echo "[depguard] Pas de docker-compose.yml — lancement manuel requis"
        log_message "INFOS" "Pas de docker-compose"
    fi

    log_message "INFOS" "Étape 3 terminée"
}

# ── Diagnostiquer un échec ────────────────────────────────
function diagnostiquer_echec() {
    log_message "ERROR" "Échec au démarrage — diagnostic LLM"
    echo ""
    echo "[depguard] Diagnostic de l'échec..."

    LOGS=$(cat /tmp/startup.log)

    PROMPT="Voici les logs de démarrage d'un projet Docker :
$LOGS

Le projet n'a pas démarré.
Identifie la cause racine en une phrase.
Donne la correction exacte.
Format :
CAUSE: explication
FICHIER: fichier à modifier
LIGNE_AVANT: ligne actuelle
LIGNE_APRES: ligne corrigée"

    DIAGNOSTIC=$(appeler_llm "$PROMPT")

    echo ""
    echo "[depguard] Diagnostic LLM :"
    echo "─────────────────────────────────"
    echo "$DIAGNOSTIC"
    echo "─────────────────────────────────"

    read -p "[depguard] Appliquer et relancer ? (o/n) : " CHOIX
    if [ "$CHOIX" = "o" ]; then
        corriger_conflits "$DIAGNOSTIC"
        etape3_lancement
    fi
}

# ══════════════════════════════════════════════════════════
# GÉNÉRER LE LOCKFILE
# ══════════════════════════════════════════════════════════

function generer_lockfile() {
    log_message "INFOS" "Génération du lockfile"
    echo ""
    echo "[depguard] Génération du lockfile..."

    # Extraire versions depuis fichiers config
    NODE_V=""
    PYTHON_V=""
    JAVA_V=""
    PHP_V=""
    GO_V=""

    [ -f "$PROJET/Dockerfile" ] && \
        NODE_V=$(grep -oP '(?<=node:)\d+' "$PROJET/Dockerfile" | head -1)
    [ -f "$PROJET/Dockerfile" ] && \
        PYTHON_V=$(grep -oP '(?<=python:)\d+\.\d+' "$PROJET/Dockerfile" | head -1)
    [ -f "$PROJET/Dockerfile" ] && \
        JAVA_V=$(grep -oP '(?<=openjdk:)\d+' "$PROJET/Dockerfile" | head -1)
    command -v php  &>/dev/null && \
        PHP_V=$(php --version 2>/dev/null | head -1 | cut -d' ' -f2)
    command -v go   &>/dev/null && \
        GO_V=$(go version 2>/dev/null | cut -d' ' -f3 | tr -d 'go')

    # Extraire services docker-compose
    SERVICES=""
    [ -f "$PROJET/docker-compose.yml" ] && \
        SERVICES=$(grep "image:" "$PROJET/docker-compose.yml" | \
                   sed 's/.*image: //' | tr -d '"' | tr '\n' ', ')

    # Extraire ports
    PORTS=""
    [ -f "$PROJET/.env" ] && \
        PORTS=$(grep -oP '\w+=\d{4,5}' "$PROJET/.env" | tr '\n' ', ')

    # Extraire variables d'environnement
    VARIABLES=""
    [ -f "$PROJET/.env" ] && \
        VARIABLES=$(grep -oP '^\w+(?==)' "$PROJET/.env" | tr '\n' ', ')

    # Extraire dépendances Python
    DEPS_PYTHON=""
    [ -f "$PROJET/requirements.txt" ] && \
        DEPS_PYTHON=$(cat "$PROJET/requirements.txt")

    # Extraire dépendances Node
    DEPS_NODE=""
    [ -f "$PROJET/package.json" ] && \
        DEPS_NODE=$(grep -A100 '"dependencies"' "$PROJET/package.json" | \
                    grep -oP '"[^"]+": "[^"]+"' | head -20 | tr '\n' ', ')

    # Extraire dépendances Java
    DEPS_JAVA=""
    [ -f "$PROJET/pom.xml" ] && \
        DEPS_JAVA=$(grep -oP '(?<=<artifactId>)[^<]+' "$PROJET/pom.xml" | \
                    tr '\n' ', ')

    # Extraire dépendances PHP
    DEPS_PHP=""
    [ -f "$PROJET/composer.json" ] && \
        DEPS_PHP=$(grep -A50 '"require"' "$PROJET/composer.json" | \
                   grep -oP '"[^"]+": "[^"]+"' | head -20 | tr '\n' ', ')

    # Extraire dépendances Go
    DEPS_GO=""
    [ -f "$PROJET/go.mod" ] && \
        DEPS_GO=$(grep "^require" -A50 "$PROJET/go.mod" | \
                  grep -v "^require\|^)" | tr -d '\t' | tr '\n' ', ')

    # Écrire le lockfile complet
    cat > "$LOCKFILE" << EOF
[meta]
date      = $(date +"%Y-%m-%d-%H-%M-%S")
projet    = $(basename $PROJET)
statut    = OPERATIONNEL

[versions_outils]
node      = ${NODE_V:-non détecté}
python    = ${PYTHON_V:-non détecté}
java      = ${JAVA_V:-non détecté}
php       = ${PHP_V:-non détecté}
go        = ${GO_V:-non détecté}

[services]
${SERVICES:-aucun service détecté}

[ports]
${PORTS:-aucun port détecté}

[variables_requises]
${VARIABLES:-aucune variable détectée}

[dependances_python]
${DEPS_PYTHON:-aucune}

[dependances_node]
${DEPS_NODE:-aucune}

[dependances_java]
${DEPS_JAVA:-aucune}

[dependances_php]
${DEPS_PHP:-aucune}

[dependances_go]
${DEPS_GO:-aucune}

[systeme]
os        = $(lsb_release -d 2>/dev/null | cut -f2 || echo "Linux")
disque    = $(df -h / | awk 'NR==2 {print $4}') libres
ram       = $(free -h | awk 'NR==2 {print $7}') disponible
EOF

    echo ""
    echo "[depguard] Lockfile généré → $LOCKFILE ✅"
    log_message "INFOS" "Lockfile généré"
    echo ""
    cat "$LOCKFILE"
}

# ══════════════════════════════════════════════════════════
# ANALYSER LE PROJET
# ══════════════════════════════════════════════════════════

function analyser_projet() {
    etape1_conflits
    etape2_systeme
    etape3_lancement
    generer_lockfile
}

# ══════════════════════════════════════════════════════════
# POINT D'ENTRÉE
# ══════════════════════════════════════════════════════════

if [ -z "$PROJET" ]; then
    erreur 101
fi

if [ ! -d "$PROJET" ]; then
    erreur 102
fi

log_message "INFOS" "depguard démarré sur $PROJET"
verifier_lockfile
