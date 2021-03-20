#! /usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /etc/bootstrap ]; then
    echo "*** changing ubuntu user" | tee -a /var/log/bootstrap.log
    usermod -u 2000 ubuntu
    groupmod -g 2000 ubuntu
    chown 2000:2000 -R /home/ubuntu

    echo "*** Setting dependencies" | tee -a /var/log/bootstrap.log
    curl https://apt.puppetlabs.com/puppet6-release-focal.deb -o /tmp/puppet6-release-focal.deb
    dpkg -i /tmp/puppet6-release-focal.deb
    rm /tmp/puppet6-release-focal.deb
    apt-get update 2>&1 | tee -a /var/log/bootstrap.log
    apt-get install -y puppet-agent vault 2>&1 | tee -a /var/log/bootstrap.log

    if [ -e /dev/sdb ]; then
        echo "*** Setting up ZFS data disk" | tee -a /var/log/bootstrap.log
        parted -s -a optimal -- /dev/sdb mkpart data '0%' '100%' 2>&1 | tee -a /var/log/bootstrap.log
        zpool create datapool /dev/sdb1 2>&1 | tee -a /var/log/bootstrap.log
        zfs create –o mountpoint=/srv  datapool/srv 2>&1 | tee -a /var/log/bootstrap.log
    fi


    echo "*** Setting up Vault credentials" | tee -a /var/log/bootstrap.log
    mac="$(ip a s | grep "brd 10.1.1.255" -B 1 | sed -n 's#^\s\+link/ether \(.*\) brd.*#\1#p' | sed 's/://g')"
    export VAULT_TOKEN="$(cat /etc/vault_token)"
    export VAULT_ADDR="https://vault.srv.gentoomaniac.net"
    vault kv get -field=role-id "puppet/bootstrap/${mac}" > /etc/vault_role_id
    vault kv get -field=secret-id "puppet/bootstrap/${mac}" > /etc/vault_secret_id
    chmod 600 /etc/vault_*
    rm /etc/vault_token


    echo "*** Regenerating ssh host keys" | tee -a /var/log/bootstrap.log
    rm -v /etc/ssh/ssh_host* 2>&1 | tee -a /var/log/bootstrap.log
    dpkg-reconfigure openssh-server 2>&1 | tee -a /var/log/bootstrap.log
    service ssh restart 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Starting initial puppet run ..." | tee -a /var/log/bootstrap.log
    systectl disable puppet-agent
    systemctl stop puppet-agent
    /opt/puppetlabs/puppet/bin/gem install vault debouncer toml-rb
    git clone https://github.com/gentoomaniac/puppet.git /tmp/puppet 2>&1 | tee -a /var/log/bootstrap.log
    sed -i 's#confdir=/var/lib/puppet-repo#confdir=/tmp/puppet#' /tmp/puppet/puppet.conf 2>&1 | tee -a /var/log/bootstrap.log

    /opt/puppetlabs/puppet/bin/puppet apply --config /tmp/puppet/puppet.conf -vvvt --modulepath=/tmp/puppet/modules/ /tmp/puppet/manifests/site.pp 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Updating the system ..." | tee -a /var/log/bootstrap.log
    apt-get upgrade -y 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Init complete" | tee -a /var/log/bootstrap.log
    systemctl disable bootstrap
    rm /etc/bootstrap /etc/systemd/system/bootstrap.service
    reboot
fi