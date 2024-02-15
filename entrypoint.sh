#!/bin/bash

set -euo pipefail

sudo mkdir -p \
    "${TELEGRAM_BOT_API_HOME}" \
    "${TELEGRAM_BOT_API_TMPDIR}" \
    "${TELEGRAM_BOT_API_VAR_LIB}" \
;
sudo chown \
    -R ${TELEGRAM_BOT_API_USER}:${TELEGRAM_BOT_API_USER} \
    "${TELEGRAM_BOT_API_HOME}" \
    "${TELEGRAM_BOT_API_TMPDIR}" \
    "${TELEGRAM_BOT_API_VAR_LIB}" \
;

telegram-bot-api \
    --dir="${TELEGRAM_BOT_API_VAR_LIB}" \
    --temp-dir="${TELEGRAM_BOT_API_TMPDIR}" \
    "$@"
