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
    local data_disk=""
    for candidate in /dev/sdb /dev/vdb; do
        if [[ -b "${candidate}" ]]; then
            data_disk="${candidate}"
            break
        fi
    done
    local data_partition="${data_disk}1"

    if [[ -n "${data_disk}" ]]; then
        if parted "${data_disk}" p 2>&1 | grep -q "Partition Table: unknown"; then
            echo "*** ${data_disk} is empty, creating partition and BTRFS datapool"
            if ! parted -s -a optimal "${data_disk}" mklabel gpt -- mkpart data btrfs '0%' '100%'; then
                echo '!!! failed writing partition table'
                exit 1
            fi
            partprobe "${data_disk}"
            udevadm settle

            if ! mkfs.btrfs -L datapool -f "${data_partition}"; then
                echo "!!! failed creating BTRFS pool on ${data_partition}"
                exit 1
            fi
        fi

        mkdir -p /srv
        if blkid -t LABEL=datapool "${data_partition}" >/dev/null 2>&1; then
            echo "*** mounting datapool on ${data_partition} ..."
            mount LABEL=datapool /srv

            if ! grep -q "LABEL=datapool /srv" /etc/fstab; then
                echo "LABEL=datapool /srv btrfs defaults,nodatacow 0 0" >> /etc/fstab
            fi
        else
            echo "!!! ${data_partition} is missing or contains an unknown filesystem. Skipping datapool mount."
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
                echo "LABEL=localpool /srv btrfs defaults,nodatacow 0 0" >> /etc/fstab
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
    cat /proc/cmdline

    echo "*** Waiting for network connectivity to Vault..."
    wait_for_network
    echo "*** Network is fully routed and DNS is responding!"

    # Same repo file and Include line as hostbase::pacman, set up before the update so it syncs too
    echo "*** Adding the homelab pacman repo ..."
    cat > /etc/pacman.d/homelab-repo <<'EOF_REPO'
[homelab]
SigLevel = Optional TrustAll
Server = https://arch.srv.gentoomaniac.net
EOF_REPO
    if ! grep -qxF 'Include = /etc/pacman.d/homelab-repo' /etc/pacman.conf; then
        echo 'Include = /etc/pacman.d/homelab-repo' >> /etc/pacman.conf
    fi

    echo "*** Updating the system ..."
    if ! pacman -Syu --noconfirm; then
        echo '!!! system update failed'
        exit 1
    fi

    echo "*** make sure some required tools are installed ..."
    for entry in curl:curl dmidecode:dmidecode docker:docker git:git nvim:neovim sshd:openssh parted:parted puppet:openvox run-puppet:run-puppet vault:vault which:which; do
        binary="${entry%%:*}"
        package="${entry##*:}"
        if ! command -v "${binary}" >/dev/null 2>&1; then
            echo "${binary} not found, installing ${package} ..."
            if ! pacman -S --needed --noconfirm "${package}"; then
                echo "!!! failed installing ${package}. exiting ..."
                exit 1
            fi
        fi
    done

    # Set up datapool on either /dev/sda4 or the second disk (/dev/sdb1 or /dev/vdb1)
    # This is mainly to cover Physical machines with only one drive
    create_data_pool

    echo "*** Setting up Vault credentials"
    export VAULT_ADDR="https://vault.srv.gentoomaniac.net"
    mac="$(awk '{gsub(/:/,""); print tolower($0)}' /sys/class/net/"$(ip route show default | awk '/default/ {print $5}')"/address)"

    if [[ -f "/etc/vault_token" ]]; then
        echo "... Getting Vault credentials from preeseeded token"
        VAULT_TOKEN="$(cat /etc/vault_token)"
        export VAULT_TOKEN
        vault kv get -field=role-id "puppet/bootstrap/${mac}" > /etc/vault_role_id
        vault kv get -field=secret-id "puppet/bootstrap/${mac}" > /etc/vault_secret_id
        chmod 600 /etc/vault_*
        rm /etc/vault_token
    else
        echo "... Getting Vault credentials from BIOS"
        dmidecode -s system-serial-number > /etc/vault_role_id
        dmidecode -s system-version > /etc/vault_secret_id
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
            echo "!!! failed enabling '${service}'"
            exit 1
        fi
    done

    echo "*** Setting up puppet automation"
    RUN_PUPPET=/usr/bin/run-puppet
    if ! gem install vault debouncer toml-rb; then
        echo "failed installing ruby gems for puppet"
        exit 1
    fi

    echo "*** Starting initial puppet run ..."
    "${RUN_PUPPET}" -vvvv --now --bin-path /usr/bin/puppet --puppet-branch "$(cat /etc/puppet_branch)"
    PUPPET_EXIT_CODE=$?
    if [ ${PUPPET_EXIT_CODE} -eq 1 ] || [ ${PUPPET_EXIT_CODE} -eq 4 ] || [ ${PUPPET_EXIT_CODE} -eq 6 ]; then
        echo "puppet initial run failed"
        exit 1
    fi

    echo "*** Starting host customisation puppet run ..."
    "${RUN_PUPPET}" -vvvv --now --bin-path /usr/bin/puppet --no-clone
    PUPPET_EXIT_CODE=$?
    if [ ${PUPPET_EXIT_CODE} -eq 1 ] || [ ${PUPPET_EXIT_CODE} -eq 4 ] || [ ${PUPPET_EXIT_CODE} -eq 6 ]; then
        echo "puppet run for host customisation failed"
        exit 1
    fi

    echo "*** Init complete"
    rm /etc/bootstrap /etc/systemd/system/bootstrap.service /usr/local/sbin/bootstrap.sh
    reboot
fi
