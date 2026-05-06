#!/usr/bin/env bash
set -euo pipefail

TABLE_NAME="${1:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/logger.sh"

DATA_DIR="$(pwd)/data"
mkdir -p "$DATA_DIR"

RAW_CSV="$DATA_DIR/${TABLE_NAME}_raw.csv"
CLEAN_CSV="$DATA_DIR/${TABLE_NAME}_clean.csv"

log_message "INFOS" "cleaner started: $TABLE_NAME"

if [[ ! -f "$TABLE_NAME" ]]; then
    log_message "ERROR" "file not found: $TABLE_NAME"
    exit 1
fi

cp "$TABLE_NAME" "$RAW_CSV"

# Etape 1 : supprimer les lignes entierement vides
grep -v '^[[:space:]]*$' "$RAW_CSV" > "${RAW_CSV}.tmp" && mv "${RAW_CSV}.tmp" "$RAW_CSV"

# Etape 2 : supprimer les doublons (en gardant l'en-tete)
HEADER=$(head -1 "$RAW_CSV")
{
    echo "$HEADER"
    tail -n +2 "$RAW_CSV" | sort | uniq
} > "${RAW_CSV}.dedup" && mv "${RAW_CSV}.dedup" "$RAW_CSV"

# Etape 3 : supprimer les lignes qui ont AU MOINS UN champ null/vide
awk -F',' '
NR == 1 { print; next }
{
    has_null = 0
    for (i = 1; i <= NF; i++) {
        gsub(/^[ \t"]+|[ \t"]+$/, "", $i)
        if ($i == "" || tolower($i) == "null") {
            has_null = 1
            break
        }
    }
    if (!has_null) print
}
' "$RAW_CSV" > "$CLEAN_CSV"

TOTAL=$(tail -n +2 "$CLEAN_CSV" | wc -l)
log_message "INFOS" "cleaner done: ${TOTAL} lignes conservees"
exit 0
