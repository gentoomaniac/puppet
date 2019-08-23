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
    ensure => file,
    owner  => 'root',
    group  => 'bind',
    source => template('dnsmaster/named.conf.options.epp', {
      cidrs      => $trusted_cidr,
      forwarders => $forwarders,
    }),
    notify => Service['bind9'],
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
    notify   => [Service['bind9'], File['/var/lib/dnsdata']],
  }
  file { '/home/marco/.dotfiles':
    ensure  => directory,
    owner   => 'root',
    group   => 'bind',
    recurse => true,
  }
}
