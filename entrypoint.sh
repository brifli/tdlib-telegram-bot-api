#!/bin/bash

set -euo pipefail

telegram-bot-api \
    --dir="${TELEGRAM_BOT_API_VAR_LIB}" \
    --temp-dir="${TELEGRAM_BOT_API_TMPDIR}" \
    "$@"
