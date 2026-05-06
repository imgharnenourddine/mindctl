#!/usr/bin/env bash
set -euo pipefail

TABLE_NAME="${1:-}"
CONTEXT_FILE="${2:-/tmp/mindctl_context.env}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/logger.sh"

CONF_FILE="$(pwd)/mindctl.conf"
MISTRAL_API_KEY=""
LLM_URL="https://api.mistral.ai/v1/chat/completions"

if [[ -f "$CONF_FILE" ]]; then
    source "$CONF_FILE"
fi

DATA_DIR="$(pwd)/data"
CLEAN_CSV="$DATA_DIR/${TABLE_NAME}_clean.csv"
REPORT="$DATA_DIR/${TABLE_NAME}_analysis.txt"

mkdir -p "$DATA_DIR"

log_message "INFOS" "analyzer started: $TABLE_NAME"

if [[ ! -f "$CLEAN_CSV" ]]; then
    log_message "ERROR" "analyzer: fichier clean introuvable: $CLEAN_CSV"
    exit 1
fi

log_message "INFOS" "analyzer: calcul des statistiques"

STATS=$(awk -F',' '
NR == 1 {
    ncols = NF
    for (i = 1; i <= NF; i++) {
        gsub(/^[ \t"]+|[ \t"]+$/, "", $i)
        headers[i] = $i
    }
    next
}
{
    total++
    for (i = 1; i <= ncols; i++) {
        val = $i
        gsub(/^[ \t"]+|[ \t"]+$/, "", val)

        if (val == "" || tolower(val) == "null") {
            nulls[i]++
        } else if (val ~ /^-?[0-9]+(\.[0-9]+)?$/) {
            sum[i]  += val
            count[i]++
        }
        key = i SUBSEP val
        if (!(key in seen)) {
            seen[key] = 1
            uniq[i]++
        }
    }
}
END {
    print "Total lignes : " total
    print "Colonnes     : " ncols
    print "---"
    for (i = 1; i <= ncols; i++) {
        printf "Colonne [%s]\n", headers[i]
        printf "  Nulls    : %d (%.1f%%)\n", nulls[i]+0, (total > 0 ? (nulls[i]+0)/total*100 : 0)
        printf "  Uniques  : %d\n", uniq[i]+0
        if (count[i] > 0)
            printf "  Moyenne  : %.2f\n", sum[i]/count[i]
    }
}
' "$CLEAN_CSV")

{
    echo "=============================="
    echo " ANALYSE — TABLE: $TABLE_NAME"
    echo " Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=============================="
    echo "$STATS"
    echo "=============================="
} > "$REPORT"

log_message "INFOS" "analyzer: statistiques calculees"
echo "$STATS"

if [[ -z "$MISTRAL_API_KEY" ]]; then
    log_message "INFOS" "analyzer: pas de cle API — interpretation LLM ignoree"
    echo "" >> "$REPORT"
    echo "LLM : non disponible (MISTRAL_API_KEY absent)" >> "$REPORT"
    exit 0
fi

log_message "INFOS" "analyzer: envoi au LLM pour interpretation"

PROMPT="Tu es un expert en analyse de donnees. Voici les statistiques d'une table nommee '${TABLE_NAME}' :

${STATS}

Reponds en 3 points courts :
1. Est-ce que ces donnees semblent saines ou problematiques ?
2. Quelle est la cause probable des anomalies detectees ?
3. Quelle action recommandes-tu ?

Sois concis, maximum 5 lignes."

PAYLOAD=$(printf '%s' "$PROMPT" | python3 -c "
import sys, json
prompt = sys.stdin.read()
payload = {
    'model': 'mistral-small-latest',
    'max_tokens': 300,
    'messages': [{'role': 'user', 'content': prompt}]
}
print(json.dumps(payload))
")

RESPONSE=$(curl -s -X POST "$LLM_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${MISTRAL_API_KEY}" \
    -d "$PAYLOAD")

LLM_TEXT=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data['choices'][0]['message']['content'])
except:
    print('LLM : erreur de parsing de la reponse')
" 2>/dev/null || echo "LLM : appel echoue")

{
    echo ""
    echo "--- INTERPRETATION LLM ---"
    echo "$LLM_TEXT"
    echo "=========================="
} >> "$REPORT"

log_message "INFOS" "analyzer: interpretation LLM recue"
echo ""
echo "--- INTERPRETATION LLM ---"
echo "$LLM_TEXT"

exit 0
