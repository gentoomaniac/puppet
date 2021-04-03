#! /usr/bin/env bash

#export DEBIAN_FRONTEND=noninteractive

if [ -f /etc/bootstrap ]; then
    echo "+++ DEBUG" | tee -a /var/log/bootstrap.log
    cat /proc/cmdline 2>&1 | tee -a /var/log/bootstrap.log
    dig repos.influxdata.com 2>&1 | tee -a /var/log/bootstrap.log
    curl https://download.docker.com/linux/ubuntu/gpg 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Disable cloud-init" | tee -a /var/log/bootstrap.log
    apt purge --assume-yes cloud-init 2>&1 | tee -a /var/log/bootstrap.log
    apt autoremove --assume-yes 2>&1 | tee -a /var/log/bootstrap.log
    rm -v /etc/netplan/50-cloud-init.yaml 2>&1 | tee -a /var/log/bootstrap.log
    #rm -v /etc/netplan/00-installer-config.yaml 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Setting dependencies" | tee -a /var/log/bootstrap.log
    curl https://apt.puppet.com/puppet7-release-focal.deb -o /tmp/puppet7-release-focal.deb
    dpkg -i /tmp/puppet7-release-focal.deb
    rm /tmp/puppet7-release-focal.deb
    apt update 2>&1 | tee -a /var/log/bootstrap.log
    apt install --assume-yes puppet-agent vault 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Updating the system ..." | tee -a /var/log/bootstrap.log
    apt upgrade --assume-yes 2>&1 | tee -a /var/log/bootstrap.log


    # Set up datapool on either /dev/sda4 or /dev/sdb1
    # This is mainly to cover Physical machines with only one drive
    if [ -b /dev/sdb ]; then
        if parted /dev/sdb p 2>&1| grep "Partition Table: unknown" -q; then
            echo "*** Setting up ZFS data disk on /dev/sdb1" | tee -a /var/log/bootstrap.log
            parted -s -a optimal /dev/sdb mklabel gpt --  mkpart data zfs '0%' '100%' 2>&1 | tee -a /var/log/bootstrap.log
            zpool create datapool /dev/sdb1 -m /srv 2>&1 | tee -a /var/log/bootstrap.log
        else
            if zpool import | grep -q ^\s\+pool: datapool$; then
                echo "*** found existing datapool. Importing ..." | tee -a /var/log/bootstrap.log
                zpool import -f datapool 2>&1 | tee -a /var/log/bootstrap.log
            else
                echo "!!! /dev/sdb has a partition table but no datapool. Skipping datapool creation/import" | tee -a /var/log/bootstrap.log
            fi
        fi
    else
        if [[ -b /dev/sda4 ]]; then
            echo "*** Setting up ZFS data disk on /dev/sda4" | tee -a /var/log/bootstrap.log
            zpool create localpool /dev/sda4 -m /srv 2>&1 | tee -a /var/log/bootstrap.log
        fi
    fi


    echo "*** Setting up Vault credentials" | tee -a /var/log/bootstrap.log
    export VAULT_ADDR="https://vault.srv.gentoomaniac.net"
    mac="$(ip a s | grep "brd 10.1.1.255" -B 1 | sed -n 's#^\s\+link/ether \(.*\) brd.*#\1#p' | sed 's/://g')"
    VAULT_TOKEN="$(cat /etc/vault_token)"
    export VAULT_TOKEN
    if [[ -z "${VAULT_TOKEN}" ]]; then
        echo "... Getting Vault credentials from BIOS" | tee -a /var/log/bootstrap.log
        dmidecode | sed -n 's/\s\+Serial Number: \(.*\)/\1/p' | head -1 > /etc/vault_secret_id
        dmidecode | sed -n 's/\s\+SKU Number: \(.*\)/\1/p' | head -1 > /etc/vault_secret_id
    else
        echo "... Getting Vault credentials from preeseeded token" | tee -a /var/log/bootstrap.log
        vault kv get -field=role-id "puppet/bootstrap/${mac}" > /etc/vault_role_id
        vault kv get -field=secret-id "puppet/bootstrap/${mac}" > /etc/vault_secret_id
    fi
    chmod 600 /etc/vault_*
    VAULT_TOKEN=$(vault write -field=token auth/approle/login role_id="$(cat /etc/vault_role_id)" secret_id="$(cat /etc/vault_secret_id)")
    export VAULT_TOKEN
    if [[ -z "${VAULT_TOKEN}" ]]; then
        echo '!!! Could not get vault token from approle' | tee -a /var/log/bootstrap.log
        exit 1
    else
        rm /etc/vault_token
    fi


    echo "*** Regenerating ssh host keys" | tee -a /var/log/bootstrap.log
    rm -v /etc/ssh/ssh_host* 2>&1 | tee -a /var/log/bootstrap.log
    dpkg-reconfigure openssh-server 2>&1 | tee -a /var/log/bootstrap.log
    service ssh restart 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Starting initial puppet run ..." | tee -a /var/log/bootstrap.log
    systectl disable puppet
    systemctl stop puppet
    /opt/puppetlabs/puppet/bin/gem install vault debouncer toml-rb
    git clone --single-branch --branch master --depth 1 https://github.com/gentoomaniac/puppet.git /tmp/puppet 2>&1 | tee -a /var/log/bootstrap.log
    sed -i 's#confdir=/var/lib/puppet-repo#confdir=/tmp/puppet#' /tmp/puppet/puppet.conf 2>&1 | tee -a /var/log/bootstrap.log

    /opt/puppetlabs/puppet/bin/puppet apply --config /tmp/puppet/puppet.conf -vvvt --modulepath=/tmp/puppet/modules/ /tmp/puppet/manifests/site.pp 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Init complete" | tee -a /var/log/bootstrap.log
    systemctl disable bootstrap
    rm /etc/bootstrap /etc/systemd/system/bootstrap.service
    reboot
fi