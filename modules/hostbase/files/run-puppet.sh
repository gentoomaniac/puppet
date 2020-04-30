#!/usr/bin/env bash

start_time=$(date +%s)

if [ "$1" != "now" ]; then
    sleep $((1 + RANDOM % 360))
    SYSLOG="-l syslog"
fi


if [ -f /etc/puppet_disable ]; then
    NOOP=--noop
fi

PATH=/sbin:/bin:/usr/sbin:/usr/bin

PUPPET=$(test -f /usr/local/bin/puppet && echo /usr/local/bin/puppet || echo /opt/puppetlabs/bin/puppet)
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

${PUPPET} apply --config "${PUPPET_GIT_PATH}/puppet.conf" -vvvt ${NOOP} ${SYSLOG} "${PUPPET_GIT_PATH}/manifests/site.pp"

puppet_returncode=$?

runtime=$[$(date +%s) - ${start_time}]
es_index_name="puppet-run-$(date +%Y-%m-%d)"
timestamp=$(date --iso-8601=seconds)
hostname=$(hostname)

curl https://elasticsearch.srv.gentoomaniac.net:9200/${es_index_name}/_doc -X POST -H 'Content-Type: application/json' -d '
{
    "@timestamp": "'${timestamp}'",
    "hostname": "'${hostname}'",
    "execution_time": '${runtime}',
    "returncode": "'${puppet_returncode}'"
}
'
