#!/usr/bin/with-contenv bash
# shellcheck shell=bash

umask "${UMASK}"

backups="${CONFIG_DIR}/app/backups"
interval="${CONFIG_DIR}/app/interval"

if [[ -f "${interval}" ]] && [[ -f "${backups}" ]]; then
    intervalnum="$(cat "${interval}")"

    echo "Going to sleep for ${intervalnum} seconds..."
    sleep "${intervalnum}"
    
    echo "Creating backups..."
    # shellcheck disable=SC1090
    source "${backups}"
else
    echo "Backup disabled, no configuration files found!"
fi
