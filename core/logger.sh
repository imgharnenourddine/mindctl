#!/usr/bin/env bash

LOG_FILE="$(pwd)/logs/mindctl.log"

mkdir -p logs

log_message() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
    local user
    user=$(whoami)
    echo "${timestamp} : ${user} : ${level} : ${msg}" | tee -a "$LOG_FILE"
}
