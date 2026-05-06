#!/usr/bin/env bash
set -euo pipefail

TABLE_NAME="${1:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../core/logger.sh"

DATA_DIR="$(pwd)/data"
CLEAN_CSV="$DATA_DIR/${TABLE_NAME}_clean.csv"
REPORT="$DATA_DIR/${TABLE_NAME}_validation.txt"

mkdir -p "$DATA_DIR"

log_message "INFOS" "validator started: $TABLE_NAME"

if [[ ! -f "$CLEAN_CSV" ]]; then
    log_message "ERROR" "missing clean file"
    exit 1
fi

echo "VALIDATION $TABLE_NAME" > "$REPORT"

ERR=$(awk -F',' '
NR == 1 { cols = NF; next }
NF != cols { err++ }
END { print err+0 }
' "$CLEAN_CSV")

echo "Errors: $ERR" >> "$REPORT"

if [[ $ERR -gt 0 ]]; then
    log_message "ERROR" "validator: ${ERR} erreur(s) detectee(s) pour $TABLE_NAME"
    exit 1
fi

log_message "INFOS" "validator done: $TABLE_NAME OK"
exit 0
