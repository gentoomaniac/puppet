#Generated by Kickstart Configurator
#platform=AMD64 or Intel EM64T

# Fetch content from here
url –url http://ubuntu.mirror.su.se/ubuntu/

#System language
lang en_GB.UTF-8

#Language modules to install
langsupport en_GB.UTF-8

#System keyboard
keyboard uk

#System timezone
timezone Etc/UTC

#Root password
rootpw --disabled

#Initial user (user with sudo capabilities) 
user marco --fullname "Marco Siebecke" --iscrypted --password $6$1PIg05ryIg$UjpEDKV9OYouO2D89GLRAKj71VLWpvKvJ1hvvWjbPu.bEA.baWZRePmdIj2KD0cTwqgTIAdiwtqZCzDHohHYI1

#Reboot after installation
reboot

#Use text mode install
text

#Install OS instead of upgrade
install

#System bootloader configuration
bootloader --location=mbr 

#Clear the Master Boot Record
zerombr yes

#Partition clearing information
clearpart --all --initlabel 

#Basic disk partition
clearpart --all --initlabel
part pv.01 --size 1 --grow
volgroup vg0 pv.01
logvol swap --fstype swap --name=swap --vgname=vg0 --size 1024
logvol / --fstype ext4 --vgname=vg0 --size=1 --grow --name=slash

# hack around Ubuntu kickstart bugs
preseed partman-lvm/confirm_nooverwrite boolean true
preseed partman-auto-lvm/no_boot        boolean true

#System authorization information 
authconfig --passalgo=sha512 --kickstart.

#Network information
network --bootproto=dhcp --device=eth0

#Firewall configuration
firewall --disabled

#Do not configure the X Window System
skipx

#Package install information
%packages
ubuntu-minimal
curl
dmidecode
git
openssh-server
puppet
screen
vim-nox


%post
exec <  /dev/tty4 > /dev/tty4
chvt 4
set -x

# setup locales
locale-gen en_GB.UTF-8
update-locale LANG="en_GB.UTF-8"
echo 'LANG=en_GB.UTF-8' >> /etc/environment
echo 'LC_ALL=en_GB.UTF-8' >> /etc/environment

# run puppet
git clone https://github.com/gentoomaniac/puppet.git /tmp/puppet 2>&1 | tee -a /var/log/kickstart.log
sed -i 's#confdir=/var/lib/puppet-repo#confdir=/tmp/puppet#' /tmp/puppet/puppet.conf 2>&1 | tee -a /var/log/kickstart.log

puppet apply --config /tmp/puppet/puppet.conf -vvvt --modulepath=/tmp/puppet/modules/ /tmp/puppet/manifests/site.pp 2>&1 | tee -a /var/log/kickstart.log

# update system
apt-get update 2>&1 | tee -a /var/log/kickstart.log
apt-get upgrade -y 2>&1 | tee -a /var/log/kickstart.log

apt-get install -f -y linux-virtual 2>&1 | tee -a /var/log/kickstart.log

chvt 1