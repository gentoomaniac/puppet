#!/usr/bin/env bash

start_time=$(date +%s)

for param in $*; do
    arg=${param/=*}
    val=${param#*=}

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

    *)
        if [[ "${arg}" = --* ]]; then
            echo "Unknown argument: ${arg}"
            exit 1
        else
            break
        fi

    esac
done

if [ "${NOW}" == "" ]; then
    sleep $((1 + RANDOM % 360))
    SYSLOG="-l syslog"
fi


if [ -f /etc/puppet_disable ]; then
    NOOP=--noop
fi

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

VAULT_BIN=$(which vault)
PUPPET=$(test -f /usr/local/bin/puppet && echo /usr/local/bin/puppet || echo /opt/puppetlabs/bin/puppet)
PUPPET_GIT_PATH=/var/lib/puppet-repo
PUPPET_GIT_BRANCH=$(head -1 /etc/puppet_branch)
temp_dir=$(mktemp -d -t puppet-$(date +%Y-%m-%d-%H-%M-%S)-XXX)

# renew vault token:
if [ ! -z "${VAULT_BIN}" ]; then
    vault token renew
fi

if [[ "${NO_CLONE}" == "" ]]; then
    if git clone --single-branch --branch "${PUPPET_GIT_BRANCH}" https://github.com/gentoomaniac/puppet.git "${temp_dir}" ; then
        rm -rf "${PUPPET_GIT_PATH}"
        mv "${temp_dir}" "${PUPPET_GIT_PATH}"
        chmod -R 755 "${PUPPET_GIT_PATH}"
    else
        logger -s "failed to clone puppet git repo"
    fi
fi

git_finished=$(date +%s)

${PUPPET} apply --config "${PUPPET_GIT_PATH}/puppet.conf" -vvvt ${NOOP} ${SYSLOG} "${PUPPET_GIT_PATH}/manifests/site.pp"

puppet_returncode=$?

es_url=http://elasticsearch.srv.gentoomaniac.net:9200
es_index_name="puppet-run-$(date +%Y.%m.%d)"
timestamp=$(date --iso-8601=seconds)
hostname=$(hostname)

git_time=$[${git_finished} - ${start_time}]
puppet_time=$[$(date +%s) - ${git_finished}]
puppet_branch=$(cat /etc/puppet_branch | tr -d '\n')

if [ "${NOOP}" == "" ]; then
    if curl -X GET "${es_url}/${es_index_name}" 2> /dev/null | grep error 2>&1 >/dev/null; then
        curl -X PUT "${es_url}/${es_index_name}" -H 'Content-Type: application/json' -d '
{
    "mappings": {
        "properties": {
        "@timestamp": {
            "type": "date"
        },
        "hostname": {
            "type": "text",
            "fields": {
                "keyword": {
                    "type": "keyword"
                }
            }
        },
        "git_time": {
            "type": "integer"
        },
        "puppet_time": {
            "type": "integer"
        },
        "puppet_branch": {
            "type": "text",
            "fields": {
                "keyword": {
                    "type": "keyword"
                }
            }
        },
        "returncode": {
            "type": "text",
            "fields": {
                "keyword": {
                    "type": "keyword"
                }
            }
        }
    }
}
'
    fi

    curl -X POST "${es_url}/${es_index_name}/_doc" -H 'Content-Type: application/json' -d '
{
    "@timestamp": "'${timestamp}'",
    "hostname": "'${hostname}'",
    "git_time": '${git_time}',
    "puppet_time": '${puppet_time}',
    "puppet_branch": "'${puppet_branch}'",
    "returncode": "'${puppet_returncode}'"
}
'
fi
