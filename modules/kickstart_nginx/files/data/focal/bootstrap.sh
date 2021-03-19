#! /usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /etc/bootstrap ]; then
    apt-get update 2>&1 | tee -a /var/log/bootstrap.log
    apt-get install -y puppet6-release puppet-agent vault 2>&1 | tee -a /var/log/bootstrap.log

    if [ -e /dev/sdb ]; then
        echo "*** Setting up ZFS data disk" | tee -a /var/log/bootstrap.log
        parted -s -a optimal -- /dev/sdb mkpart data '0%' '100%' 2>&1 | tee -a /var/log/bootstrap.log
        zpool create datapool /dev/sdb1 2>&1 | tee -a /var/log/bootstrap.log
        zfs create –o mountpoint=/srv  datapool/srv 2>&1 | tee -a /var/log/bootstrap.log
    fi


    echo "*** Regenerating ssh host keys" | tee -a /var/log/bootstrap.log
    rm -v /etc/ssh/ssh_host* 2>&1 | tee -a /var/log/bootstrap.log
    dpkg-reconfigure openssh-server 2>&1 | tee -a /var/log/bootstrap.log
    service ssh restart 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Starting initial puppet run ..." | tee -a /var/log/bootstrap.log
    git clone https://github.com/gentoomaniac/puppet.git /tmp/puppet 2>&1 | tee -a /var/log/bootstrap.log
    sed -i 's#confdir=/var/lib/puppet-repo#confdir=/tmp/puppet#' /tmp/puppet/puppet.conf 2>&1 | tee -a /var/log/bootstrap.log

    /opt/puppetlabs/puppet/bin/puppet apply --config /tmp/puppet/puppet.conf -vvvt --modulepath=/tmp/puppet/modules/ /tmp/puppet/manifests/site.pp 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Updating the system ..." | tee -a /var/log/bootstrap.log
    apt-get upgrade -y 2>&1 | tee -a /var/log/bootstrap.log


    echo "*** Deleting setup user" | tee -a /var/log/bootstrap.log
    userdel ubuntu
    rm -rf /home/ubuntu
    sudo sed -i '/^ubuntu/d' /etc/sudoers

    echo "*** Init complete" | tee -a /var/log/bootstrap.log
    systemctl disable bootstrap
    rm /etc/bootstrap /etc/systemd/system/bootstrap.service
    reboot
fi