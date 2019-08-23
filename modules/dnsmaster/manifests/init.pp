# Class: dnsmaster
#
#
class dnsmaster {
  $bind_packages = ['bind9', 'bind9utils', 'bind9-doc']

  package { 'bind9':
    ensure => latest,
  }
}
