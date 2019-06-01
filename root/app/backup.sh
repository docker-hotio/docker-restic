#!/usr/bin/with-contenv bash
# shellcheck shell=bash

umask "${UMASK}"

while :; do
    interval="$(cat "${CONFIG_DIR}/app/interval")"
    backups="${CONFIG_DIR}/app/backups"
    echo "Going to sleep for ${interval} seconds..."
    sleep "${interval}"
    echo "Executing backups from: ${backups}"
    # shellcheck disable=SC1090
    source "${backups}"
done
