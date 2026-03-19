#!/usr/bin/env bash

archinstall --config-url https://ks.srv.gentoomaniac.net/arch/vm.json --creds-url https://ks.srv.gentoomaniac.net/arch/creds.json --silent

# seed vault token
sed -n 's/.*VAULT_TOKEN=\([a-zA-Z0-9\.]\+\).*/\1/p' /proc/cmdline > /mnt/etc/vault_token
chmod 600 /mnt/etc/vault_token

# puppet branch
PUPPET_BRANCH=$(sed -n 's/.*PUPPET_BRANCH=\([a-zA-Z0-9\._-/]\+\).*/\1/p' /proc/cmdline); echo ${PUPPET_BRANCH:-arch} > /mnt/etc/puppet_branch

# setup bootstrap script
touch /mnt/etc/bootstrap
curl https://ks.srv.gentoomaniac.net/arch/bootstrap.sh -o /mnt/usr/local/sbin/bootstrap.sh
chmod +x /mnt/usr/local/sbin/bootstrap.sh
curl https://ks.srv.gentoomaniac.net/arch/bootstrap.service -o /mnt/etc/systemd/system/bootstrap.service
ln -s /etc/systemd/system/bootstrap.service /mnt/etc/systemd/system/multi-user.target.wants/bootstrap.service

# boot the new system
sync
reboot
