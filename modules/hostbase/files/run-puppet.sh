#!/usr/bin/env bash

start_time=$(date +%s)

for param in $*; do
    arg=${param/=*}

    case ${arg} in

    --no-clone)
        NO_CLONE=true
        shift
        ;;

    --noop)
        NOOP=--noop
        shift
        ;;

    --now)
        NOW=true
        shift
        ;;

    --verbose)
        set -x
        shift
        ;;

    *)
        if [[ "${arg}" = --* ]]; then
            echo "Unknown argument: ${arg}"
            exit 1
        else
            break
        fi

    esac
done

if [ -z "${NOW}" ]; then
    sleep $((1 + RANDOM % 360))
    SYSLOG="-l syslog"
fi


if [ -f /etc/puppet_disable ] && [ -z "${NOW}" ]; then
    NOOP=--noop
fi

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/snap/bin

VAULT_BIN=$(which vault)
export VAULT_ADDR=https://vault.srv.gentoomaniac.net/
PUPPET=$(test -f /usr/local/bin/puppet && echo /usr/local/bin/puppet || echo /opt/puppetlabs/bin/puppet)
PUPPET_GIT_PATH=/var/lib/puppet-repo
PUPPET_GIT_BRANCH=$(head -1 /etc/puppet_branch)
temp_dir=$(mktemp -d -t "puppet-$(date +%Y-%m-%d-%H-%M-%S)-XXX")
influxdb_host="https://influxdb.srv.gentoomaniac.net:8086"

export VAULT_SKIP_VERIFY=True

# renew vault token:
if [ -n "${VAULT_BIN}" ]; then
    VAULT_TOKEN=$(vault write -field=token auth/approle/login role_id="$(cat /etc/vault_role_id)" secret_id="$(cat /etc/vault_secret_id)")
    export VAULT_TOKEN
else
    echo "Vault binary not found"
    exit 1
fi

if [[ "${NO_CLONE}" == "" ]]; then
    if git clone --single-branch --branch "${PUPPET_GIT_BRANCH}" --depth 1 https://github.com/gentoomaniac/puppet.git "${temp_dir}" ; then
        rm -rf "${PUPPET_GIT_PATH}"
        mv "${temp_dir}" "${PUPPET_GIT_PATH}"
        chmod -R 755 "${PUPPET_GIT_PATH}"
    else
        logger -s "failed to clone puppet git repo"
    fi
fi

git_finished=$(date +%s)

# shellcheck disable=SC2086
${PUPPET} apply --config "${PUPPET_GIT_PATH}/puppet.conf" -vvvt ${NOOP} ${SYSLOG} "${PUPPET_GIT_PATH}/manifests/site.pp"


puppet_returncode=$?
git_time=$((git_finished - start_time))
puppet_time=$(($(date +%s) - git_finished))
puppet_branch=$(tr -d '\n' </etc/puppet_branch)

influx_user="$(vault kv get -field=user puppet/common/influxdb_puppet_runs)"
influx_pw="$(vault kv get -field=password puppet/common/influxdb_puppet_runs)"
curl -i -XPOST "${influxdb_host}/write?db=puppet_runs" -u "${influx_user}:${influx_pw}" --data-binary "puppet_returncode,hostname=$(hostname),puppet_branch=${puppet_branch} value=${puppet_returncode}"
curl -i -XPOST "${influxdb_host}/write?db=puppet_runs" -u "${influx_user}:${influx_pw}" --data-binary "puppet_time,hostname=$(hostname),puppet_branch=${puppet_branch} value=${puppet_time}"
curl -i -XPOST "${influxdb_host}/write?db=puppet_runs" -u "${influx_user}:${influx_pw}" --data-binary "puppet_git_time,hostname=$(hostname),puppet_branch=${puppet_branch} value=${git_time}"
