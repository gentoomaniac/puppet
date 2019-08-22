# Class: hostbase::raspberrypi
#
class hostbase::raspberrypi {
  package { 'cloud-init':
    ensure => 'purged',
  }

  file { '/etc/netplan/50-cloud-init.yaml':
    ensure => 'absent',
  }
}
