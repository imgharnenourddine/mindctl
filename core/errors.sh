#!/bin/bash

source ~/mindctl/core/logger.sh

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
    echo "AGENTS DISPONIBLES :"
    echo "  depguard | cleaner | analyzer"
    echo "  transformer | validator | insight"
    echo ""
    echo "CODES D'ERREUR :"
    echo "  100 → Option inexistante"
    echo "  101 → Paramètre -p manquant"
    echo "  102 → Fichier introuvable"
    echo "  103 → Permission refusée"
    echo "  104 → Format non supporté"
    echo "  105 → API inaccessible"
    echo "  106 → Agent inconnu"
    echo "  107 → Échec du traitement"
    echo ""
}

function erreur() {
    local CODE="$1"
    local MESSAGE=""

    case $CODE in
        100) MESSAGE="Option inexistante" ;;
        101) MESSAGE="Paramètre obligatoire manquant : -p <fichier>" ;;
        102) MESSAGE="Fichier ou dossier introuvable" ;;
        103) MESSAGE="Permission refusée — droits administrateur requis" ;;
        104) MESSAGE="Format de fichier non supporté" ;;
        105) MESSAGE="API Mistral inaccessible — vérifiez votre clé API" ;;
        106) MESSAGE="Agent inconnu — utilisez -h pour voir les agents disponibles" ;;
        107) MESSAGE="Échec du traitement" ;;
        *)   MESSAGE="Erreur inconnue" ;;
    esac

    log_message "ERROR" "Code $CODE — $MESSAGE"
    echo ""
    echo "[ERREUR $CODE] $MESSAGE"
    echo ""
    afficher_aide
   # exit $CODE
}
