#!/usr/bin/env bash

VAULT_BIN=$(which vault)
export VAULT_ADDR=https://vault.srv.gentoomaniac.net/

# renew vault token:
if [ -n "${VAULT_BIN}" ]; then
    VAULT_TOKEN=$(vault write -field=token auth/approle/login role_id="$(cat /etc/vault_role_id)" secret_id="$(cat /etc/vault_secret_id)")
    export VAULT_TOKEN
else
    echo "Vault binary not found"
    exit 1
fi

${VAULT_BIN} "$@"
