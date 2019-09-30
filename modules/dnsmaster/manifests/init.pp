# Class: dnsmaster
#
#
class dnsmaster (
  $trusted_cidr,
  $forwarders,
) {
  $bind_packages = ['bind9', 'bind9utils', 'bind9-doc']

  package { $bind_packages :
    ensure => latest,
  }

  file_line { 'usr.sbin.named.dnsdata':
    ensure  => present,
    path    => '/etc/apparmor.d/usr.sbin.named',
    line    => '  /var/lib/dnsdata/** r,',
    after   => '.*#include <local/usr.sbin.named>',
    require => Package[$bind_packages],
    notify  => Service['apparmor']
  }

  service { 'apparmor':
    ensure => running,
    enable => true,
  }

  file { '/etc/default/bind9':
    ensure  => file,
    source  => 'puppet:///modules/dnsmaster/defaults',
    notify  => Service['bind9'],
    require => Package[$bind_packages],
  }
  file { '/etc/bind/named.conf.local':
    ensure => file,
    owner  => 'root',
    group  => 'bind',
    source => 'puppet:///modules/dnsmaster/named.conf.local',
    notify => Service['bind9'],
  }
  file { '/etc/bind/named.conf.options':
    ensure  => file,
    owner   => 'root',
    group   => 'bind',
    content => epp('dnsmaster/named.conf.options.epp', {
      cidrs      => $trusted_cidr,
      forwarders => $forwarders,
    }),
    notify  => Service['bind9'],
  }
  service { 'bind9':
    ensure  => running,
    enable  => true,
    require => [Package[$bind_packages], Vcsrepo['/var/lib/dnsdata']],
  }

  vcsrepo { '/var/lib/dnsdata':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dnsdata.git',
    revision => 'master',
    notify   => [Service['bind9'], Exec['dnsdata-permissions']],
  }
  exec { 'dnsdata-permissions':
    command     => '/bin/chown -R root.bind /var/lib/dnsdata',
    refreshonly => true,
  }
}
