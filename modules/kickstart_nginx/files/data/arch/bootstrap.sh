#! /usr/bin/env bash

# Set up global logging
LOG_FILE="/var/log/bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

function wait_for_network() {
    until ping -c 1 -W 2 vault.srv.gentoomaniac.net >/dev/null 2>&1; do
        sleep 2
    done
}

function create_data_pool() {
    if [ -b /dev/sdb ]; then
        if parted /dev/sdb p 2>&1 | grep -q "Partition Table: unknown"; then
            echo "*** /dev/sdb is empty, creating partition and BTRFS datapool"
            if ! parted -s -a optimal /dev/sdb mklabel gpt -- mkpart data btrfs '0%' '100%'; then
                echo '!!! failed writing partition table'
                exit 1
            fi
            partprobe /dev/sdb
            udevadm settle
            
            if ! mkfs.btrfs -L datapool -f /dev/sdb1; then
                echo "!!! failed creating BTRFS pool on /dev/sdb1"
                exit 1
            fi
        fi

        mkdir -p /srv
        if blkid -t LABEL=datapool /dev/sdb1 >/dev/null 2>&1; then
            echo "*** mounting datapool on /dev/sdb1 ..."
            mount LABEL=datapool /srv
            
            if ! grep -q "LABEL=datapool /srv" /etc/fstab; then
                echo "LABEL=datapool /srv btrfs defaults 0 0" >> /etc/fstab
            fi
        else
            echo "!!! /dev/sdb1 is missing or contains an unknown filesystem. Skipping datapool mount." 
            return
        fi
    elif [[ -b /dev/sda4 ]]; then
        if ! blkid /dev/sda4 >/dev/null 2>&1; then
            echo "*** /dev/sda4 is empty, setting up BTRFS localpool"
            if ! mkfs.btrfs -L localpool -f /dev/sda4; then
                echo "!!! failed creating BTRFS pool on /dev/sda4"
                exit 1
            fi
        fi

        mkdir -p /srv
        if blkid -t LABEL=localpool /dev/sda4 >/dev/null 2>&1; then
            echo "*** mounting localpool on /dev/sda4 ..." 
            mount LABEL=localpool /srv
            if ! grep -q "LABEL=localpool /srv" /etc/fstab; then
                echo "LABEL=localpool /srv btrfs defaults 0 0" >> /etc/fstab
            fi
        else
            echo "!!! /dev/sda4 contains an unknown filesystem. Skipping localpool creation to prevent data loss." 
            return
        fi
    else
        echo "No separate data partition or disk detected." 
        return
    fi
}

if [ -f /etc/bootstrap ]; then
    echo "+++ DEBUG" 
    cat /proc/cmdline

    echo "*** Waiting for network connectivity to Vault..." 
    wait_for_network
    echo "*** Network is fully routed and DNS is responding!"

    echo "*** Updating the system ..." 
    if ! pacman -Syu --noconfirm; then
        echo '!!! system update failed'
        exit 1
    fi

    # Set up datapool on either /dev/sda4 or /dev/sdb1
    # This is mainly to cover Physical machines with only one drive
    create_data_pool

    echo "*** Setting up Vault credentials"
    export VAULT_ADDR="https://vault.srv.gentoomaniac.net"
    mac="$(ip a s | grep "brd 10.1.1.255" -B 1 | sed -n 's#^\s\+link/ether \(.*\) brd.*#\1#p' | sed 's/://g')"

    if [[ -f "/etc/vault_token" ]]; then
        echo "... Getting Vault credentials from preeseeded token" 
        VAULT_TOKEN="$(cat /etc/vault_token)"
        export VAULT_TOKEN
        vault kv get -field=role-id "puppet/bootstrap/${mac}" > /etc/vault_role_id
        vault kv get -field=secret-id "puppet/bootstrap/${mac}" > /etc/vault_secret_id
        rm /etc/vault_token
    else
        echo "... Getting Vault credentials from BIOS" 
        dmidecode | sed -n 's/\s\+Serial Number: \(.*\)/\1/p' | head -1 > /etc/vault_role_id
        dmidecode | sed -n 's/\s\+SKU Number: \(.*\)/\1/p' | head -1 > /etc/vault_secret_id
        chmod 600 /etc/vault_*
        VAULT_TOKEN=$(vault write -field=token auth/approle/login role_id="$(cat /etc/vault_role_id)" secret_id="$(cat /etc/vault_secret_id)")
        export VAULT_TOKEN
    fi

    if [[ -z "${VAULT_TOKEN}" ]]; then
        echo '!!! Could not get vault token from approle'
        exit 1
    fi

    echo "*** Enable services"
    for service in sshd docker; do
        if ! systemctl enable --now "${service}"; then
            echo "!!! failed enabling "${service}""
            exit 1
        fi
    done

    echo "*** Setting up puppet automation"
    RUN_PUPPET=/usr/local/sbin/run-puppet
    curl -L https://github.com/gentoomaniac/run-puppet/releases/download/v0.1.6/run-puppet_0.1.6_linux-amd64 -o "${RUN_PUPPET}" 
    if [ ! -f "${RUN_PUPPET}" ]; then
        echo "failed fetching run-puppet"
        exit 1
    fi
    chmod +x "${RUN_PUPPET}"
    if ! gem install vault debouncer toml-rb; then
        echo "failed installing ruby gems for puppet"
        exit 1
    fi

    echo "*** Starting initial puppet run ..." 
    "${RUN_PUPPET}" -vvvv --now --bin-path /usr/bin/puppet --puppet-branch "$(cat /etc/puppet_branch)"
    PUPPET_EXIT_CODE=$?
    if [ ${PUPPET_EXIT_CODE} -eq 1 ] || [ ${PUPPET_EXIT_CODE} -eq 4 ] || [ ${PUPPET_EXIT_CODE} -eq 6 ]; then
        exit "puppet initial run failed"
        exit 1
    fi

    echo "*** Starting host customisation puppet run ..." 
    "${RUN_PUPPET}" -vvvv --now --bin-path /usr/bin/puppet --puppet-branch "$(cat /etc/puppet_branch)"
    PUPPET_EXIT_CODE=$?
    if [ ${PUPPET_EXIT_CODE} -eq 1 ] || [ ${PUPPET_EXIT_CODE} -eq 4 ] || [ ${PUPPET_EXIT_CODE} -eq 6 ]; then
        exit "puppet run for host customisation failed"
        exit 1
    fi

    echo "*** Init complete" 
    rm /etc/bootstrap /etc/systemd/system/bootstrap.service /usr/local/sbin/bootstrap.sh 
    reboot
fi
