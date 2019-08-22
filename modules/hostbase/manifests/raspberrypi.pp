# Class: hostbase::raspberrypi
#
class hostbase::raspberrypi {
  package { 'cloud-init':
    ensure => 'purged',
  }
}
