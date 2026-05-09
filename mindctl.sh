#!/bin/bash

source ~/mindctl/mindctl.conf
source ~/mindctl/core/logger.sh
source ~/mindctl/core/errors.sh

# ── Variables globales ────────────────────────────────────
AGENT=""
PARAMETRE=""
MODE="subshell"
LOG_DIR="$MINDCTL_LOG_DIR"
PIPELINE=false

# ── Afficher aide ─────────────────────────────────────────
function afficher_aide() {
    echo ""
    echo "UTILISATION : mindctl [options] -p <paramètre>"
    echo ""
    echo "OPTIONS :"
    echo "  -h              Affiche cette aide"
    echo "  -f              Exécution via fork"
    echo "  -t              Exécution via threads"
    echo "  -s              Exécution via subshell"
    echo "  -l <dossier>    Dossier des logs"
    echo "  -r              Réinitialise la config (admin)"
    echo "  -a <agent>      Choisit l'agent"
    echo "  -p <chemin>     Fichier à analyser (OBLIGATOIRE)"
    echo "  -w              Mode pipeline"
    echo ""
}

# ── Vérifier root ─────────────────────────────────────────
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        erreur 103
    fi
}

# ── Lancer un agent ───────────────────────────────────────
function lancer_agent() {
    local AGENT_PATH="~/mindctl/agents/$AGENT.sh"

    case $MODE in
        subshell)
            log_message "INFOS" "Lancement $AGENT en subshell"
            ( bash ~/mindctl/agents/$AGENT.sh "$PARAMETRE" )
            ;;
        fork)
            log_message "INFOS" "Lancement $AGENT en fork"
            ~/mindctl/helpers/fork_agent "$AGENT" "$PARAMETRE"
            ;;
        thread)
            log_message "INFOS" "Lancement $AGENT en thread"
            ~/mindctl/helpers/thread_agent "$AGENT" "$PARAMETRE"
            ;;
    esac
}

# ── Mode pipeline ─────────────────────────────────────────
function lancer_pipeline() {
    log_message "INFOS" "Démarrage pipeline complet"

    AGENT="depguard"  && lancer_agent
    AGENT="cleaner"   && lancer_agent
    AGENT="analyzer"  && lancer_agent
    AGENT="insight"   && lancer_agent

    log_message "INFOS" "Pipeline terminé"
}

# ── Parser les options ────────────────────────────────────
while getopts "hftsl:ra:p:w" OPT; do
    case $OPT in
        h) afficher_aide ; exit 0 ;;
        f) MODE="fork" ;;
        t) MODE="thread" ;;
        s) MODE="subshell" ;;
        l) LOG_DIR="$OPTARG" ;;
        r) check_root ;;
        a) AGENT="$OPTARG" ;;
        p) PARAMETRE="$OPTARG" ;;
        w) PIPELINE=true ;;
        *) erreur 100 ;;
    esac
done

# ── Vérifier paramètre obligatoire ────────────────────────
if [ -z "$PARAMETRE" ]; then
    erreur 101
fi

# ── Vérifier agent valide ─────────────────────────────────
AGENTS_VALIDES=("depguard" "cleaner" "analyzer" "transformer" "validator" "insight")

if [ -n "$AGENT" ]; then
    VALIDE=false
    for A in "${AGENTS_VALIDES[@]}"; do
        [ "$A" = "$AGENT" ] && VALIDE=true
    done
    [ "$VALIDE" = false ] && erreur 106
fi

# ── Exécution ─────────────────────────────────────────────
log_message "INFOS" "mindctl démarré — agent:$AGENT paramètre:$PARAMETRE mode:$MODE"

if [ "$PIPELINE" = true ]; then
    lancer_pipeline
else
    lancer_agent
fi
