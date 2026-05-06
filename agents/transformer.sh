#!/usr/bin/env bash
set -euo pipefail

TABLE_NAME="${1:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/logger.sh"

DATA_DIR="$(pwd)/data"

CLEAN_CSV="$DATA_DIR/${TABLE_NAME}_clean.csv"
JSON_OUT="$DATA_DIR/${TABLE_NAME}.json"

mkdir -p "$DATA_DIR"

log_message "INFOS" "transformer started: $TABLE_NAME"

if [[ ! -f "$CLEAN_CSV" ]]; then
    log_message "ERROR" "missing clean file"
    exit 1
fi

# Conversion CSV -> JSON avec virgules correctes entre objets
awk -F',' '
NR == 1 {
    ncols = NF
    for (i = 1; i <= NF; i++) {
        gsub(/^[ \t"]+|[ \t"]+$/, "", $i)
        h[i] = $i
    }
    print "["
    next
}
{
    if (NR > 2) print "  ,"
    printf "  {"
    for (i = 1; i <= ncols; i++) {
        val = $i
        gsub(/^[ \t"]+|[ \t"]+$/, "", val)
        if (i < ncols)
            printf "\"%s\":\"%s\",", h[i], val
        else
            printf "\"%s\":\"%s\"", h[i], val
    }
    print "}"
}
END {
    print "]"
}
' "$CLEAN_CSV" > "$JSON_OUT"

RECORDS=$(grep -c '{' "$JSON_OUT" || echo 0)
log_message "INFOS" "transformer done: ${RECORDS} enregistrement(s) -> ${JSON_OUT}"
exit 0
