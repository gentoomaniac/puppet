#!/usr/bin/env bash

for param in $*; do
    arg=${param/=*}
    value=${param##*=}

    case ${arg} in

    --email)
        email=${value}
        shift
        ;;

    --domain)
        domain=${value}
        shift
        ;;

    --image)
        certbot_image=${value}
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

normalized=$(sed -e 's/\*\.//g; s/\./_/g' <<<${domain})
simpledomain=$(sed -e 's/\*\.//g' <<<${domain})

now=$(date "+%s")
cert_path="/srv/certbot-${normalized}/data/live/${simpledomain}"
cert_date=$(keytool -printcert -file "${cert_path}/fullchain.pem" | sed -n '1,10 s/.*until: \(.*\)/\1/p')
cert_timestamp=$(date -d "${cert_date}" "+%s")

certbot_parameters="certonly --dns-google --dns-google-credentials /sa.json --email ${email} --agree-tos --no-eff-email -d ${domain}"

# cert valid less than 30 days
if (( $(( ${cert_timestamp} - ${now} )) < 2592000 )); then
    docker run -n certbot --rm -v "/srv/certbot-${normalized}/sa.json:/sa.json:ro" -v "/srv/certbot-${normalized}/data:/etc/letsencrypt" ${certbot_image} ${certbot_parameters} && {
        /usr/local/bin/mvault kv put puppet/common/secret_${normalized}_cert value="$(cat ${cert_path}/fullchain.pem)"
        /usr/local/bin/mvault kv put puppet/common/secret_${normalized}_key value="$(cat ${cert_path}/privkey.pem)"
    }
fi