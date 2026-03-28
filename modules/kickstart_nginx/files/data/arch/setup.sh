#!/usr/bin/env bash

# get bootstrap config from /proc/cmdline
KICKSTART_BASE_URL=$(sed -n 's/.*KICKSTART_BASE_URL=\([^ ]\+\).*/\1/p' /proc/cmdline)
KICKSTART_BASE_URL=${KICKSTART_BASE_URL:-https://ks.srv.gentoomaniac.net}
PUPPET_BRANCH=$(sed -n 's/.*PUPPET_BRANCH=\([a-zA-Z0-9\._-]\+\).*/\1/p' /proc/cmdline)
VAULT_TOKEN=$(sed -n 's/.*VAULT_TOKEN=\([a-zA-Z0-9\.]\+\).*/\1/p' /proc/cmdline)

# Run archinstall and catch failures!
if ! archinstall --config-url "${KICKSTART_BASE_URL}/arch/vm.json" --creds-url "${KICKSTART_BASE_URL}/arch/creds.json" --silent; then
    echo -e "\n\e[31m!!! archinstall failed! Dropping to shell ...\e[0m"
    exit 1
fi

# Ensure all target directories exist before we try to write to them
mkdir -p /mnt/etc/systemd/system/multi-user.target.wants
mkdir -p /mnt/usr/local/sbin

# persist some of the config
if [ ! -z "${VAULT_TOKEN}" ]; then
    echo "${VAULT_TOKEN}" > /mnt/etc/vault_token
    chmod 600 /mnt/etc/vault_token
fi
echo "${PUPPET_BRANCH:-arch}" > /mnt/etc/puppet_branch


# setup bootstrap script
touch /mnt/etc/bootstrap
curl "${KICKSTART_BASE_URL}/arch/bootstrap.sh" -o /mnt/usr/local/sbin/bootstrap.sh
chmod +x /mnt/usr/local/sbin/bootstrap.sh
curl "${KICKSTART_BASE_URL}/arch/bootstrap.service" -o /mnt/etc/systemd/system/bootstrap.service
ln -s /etc/systemd/system/bootstrap.service /mnt/etc/systemd/system/multi-user.target.wants/bootstrap.service

# boot the new system
sync
reboot
