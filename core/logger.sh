#!/bin/bash

# Charger la configuration
source ~/mindctl/mindctl.conf

# Créer le dossier de logs si inexistant
mkdir -p "$MINDCTL_LOG_DIR"

# ── Fonction principale ───────────────────────────────────
function log_message() {

    local TYPE="$1"     # INFOS ou ERROR
    local MESSAGE="$2"  # le message à afficher

    # Générer la date au format imposé par le prof
    local DATE=$(date +"%Y-%m-%d-%H-%M-%S")

    # Récupérer l'utilisateur connecté
    local USER=$(whoami)

    # Construire la ligne complète
    local LIGNE="$DATE : $USER : $TYPE : $MESSAGE"

    # Écrire simultanément terminal + fichier log
    echo "$LIGNE" | tee -a "$MINDCTL_LOG_DIR/history.log"
}
