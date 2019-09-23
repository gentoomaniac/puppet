#!/usr/bin/env bash

sleep $((1 + RANDOM % 360))

PATH=${PATH}:/usr/local/bin/puppet:/opt/puppetlabs/bin

PUPPET_GIT_PATH=/var/lib/puppet-repo
PUPPET_GIT_BRANCH=$(head -1 /etc/puppet_branch)
temp_dir=$(mktemp -d -t puppet-$(date +%Y-%m-%d-%H-%M-%S)-XXX)

if git clone --single-branch --branch "${PUPPET_GIT_BRANCH}" https://github.com/gentoomaniac/puppet.git "${temp_dir}" ; then
    rm -rf "${PUPPET_GIT_PATH}"
    mv "${temp_dir}" "${PUPPET_GIT_PATH}"
    chmod -R 755 "${PUPPET_GIT_PATH}"
else
    logger -s "failed to clone puppet git repo"
fi

puppet apply --config "${PUPPET_GIT_PATH}/puppet.conf" -vvvt -l syslog "${PUPPET_GIT_PATH}/manifests/site.pp"
