# Class: dnsmaster
#
#
class dnsmaster {
  $bind_packages = ['bind9', 'bind9utils', 'bind9-doc']

  package { $bind_packages :
    ensure => latest,
  }

  file { '/etc/default/bind9':
    ensure => file,
    source => 'puppet:///modules/dnsmaster/defaults',
    notify => Service['bind9'],
  }

  service { 'bind9':
    ensure  => running,
    enable  => true,
    require => Package[$bind_packages],
  }

  vcsrepo { '/var/lib/dnsdata':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dnsdata.git',
    revision => 'master',
    notify   => Service['bind9'],
  }
}
