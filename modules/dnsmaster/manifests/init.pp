# Class: dnsmaster
#
#
class dnsmaster {
  $bind_packages = ['bind9', 'bind9utils', 'bind9-doc']

  package { $bind_packages :
    ensure => latest,
  }
}
