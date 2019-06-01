#!/usr/bin/with-contenv bash
# shellcheck shell=bash

umask "${UMASK}"

backups="${CONFIG_DIR}/app/backups"
interval="${CONFIG_DIR}/app/interval"
onstart="${CONFIG_DIR}/app/onstart"

if [[ -f "${onstart}" ]] && [[ -f "${backups}" ]]; then
    echo "Creating backups..."
    # shellcheck disable=SC1090
    source "${backups}"
fi

if [[ -f "${interval}" ]] && [[ -f "${backups}" ]]; then
    while :; do
        intervalnum="$(cat "${interval}")"

        echo "Going to sleep for ${intervalnum} seconds..."
        sleep "${intervalnum}"
        
        echo "Creating backups..."
        # shellcheck disable=SC1090
        source "${backups}"
    done
fi

exit 0
