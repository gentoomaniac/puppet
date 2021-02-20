#! /usr/bin/env bash

if [ ! -f /etc/init_complete ]; then
    echo "Deleting setup user" | tee -a /var/log/init.log
    userdel ubuntu
    rm -rf /home/ubuntu
    sudo sed -i '/^ubuntu/d' /etc/sudoers

    echo "Regenerating ssh host keys" | tee -a /var/log/init.log
    rm -v /etc/ssh/ssh_host* 2>&1 | tee -a /var/log/init.log
    dpkg-reconfigure openssh-server 2>&1 | tee -a /var/log/init.log
    service ssh restart 2>&1 | tee -a /var/log/init.log


    echo "Starting initial puppet run ..." | tee -a /var/log/init.log
    git clone https://github.com/gentoomaniac/puppet.git /tmp/puppet 2>&1 | tee -a /var/log/init.log
    sed -i 's#confdir=/var/lib/puppet-repo#confdir=/tmp/puppet#' /tmp/puppet/puppet.conf 2>&1 | tee -a /var/log/init.log

    /opt/puppetlabs/puppet/bin/puppet apply --config /tmp/puppet/puppet.conf -vvvt --modulepath=/tmp/puppet/modules/ /tmp/puppet/manifests/site.pp 2>&1 | tee -a /var/log/init.log


    echo "Updating the system ..." | tee -a /var/log/init.log
    apt-get update 2>&1 | tee -a /var/log/init.log
    apt-get upgrade -y 2>&1 | tee -a /var/log/init.log

    echo "Init complete" | tee -a /var/log/init.log
    touch /etc/init_complete
    reboot
fi
