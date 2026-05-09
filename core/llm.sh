#!/bin/bash

source ~/mindctl/mindctl.conf
source ~/mindctl/core/logger.sh
source ~/mindctl/core/errors.sh

function appeler_llm() {

    local PROMPT="$1"

    # Vérifier que la clé API est configurée
    if [ -z "$MISTRAL_API_KEY" ]; then
        erreur 105
    fi

    # Appel à l'API Mistral AI
    local REPONSE=$(curl -s \
        -X POST "$LLM_URL" \
        -H "Authorization: Bearer $MISTRAL_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MINDCTL_MODEL\",
            \"messages\": [
                {
                    \"role\": \"user\",
                    \"content\": \"$PROMPT\"
                }
            ]
        }")

    # Vérifier si l'appel a réussi
    if [ -z "$REPONSE" ]; then
        log_message "ERROR" "API Mistral — aucune réponse reçue"
        erreur 105
    fi

    # Extraire uniquement le texte de la réponse
    local TEXTE=$(echo "$REPONSE" | jq -r '.choices[0].message.content')

    log_message "INFOS" "API Mistral — réponse reçue"

    echo "$TEXTE"
}
