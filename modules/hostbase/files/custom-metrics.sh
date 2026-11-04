#!/usr/bin/env bash

set -o pipefail

# shellcheck source=/dev/null
OS_NAME="$(source /etc/os-release && echo "${PRETTY_NAME}")"
PENDING_UPDATES="$(checkupdates 2>/dev/null | wc -l)"
PENDING_SEC_UPDATES="$(arch-audit -uq 2>/dev/null | wc -l)"

# Calculate standard patch updates safely
PATCH_UPDATES=$(( PENDING_UPDATES - PENDING_SEC_UPDATES ))
if [ "${PATCH_UPDATES}" -lt 0 ]; then PATCH_UPDATES=0; fi

echo "lsb_release value=1,release=\"${OS_NAME}\""
echo "pending_updates,type=patch value=${PATCH_UPDATES}"
echo "pending_updates,type=security value=${PENDING_SEC_UPDATES}"
echo "puppet_branch value=1,branch=\"$(head -1 /etc/puppet_branch 2>/dev/null || echo 'unknown')\""
