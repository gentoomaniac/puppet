
class hostbase::autoupdate {
  package { 'unattended-upgrades':
    ensure => latest,
  }

  file { '/etc/apt/apt.conf.d/50unattended-upgrades':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/hostbase/50unattended-upgrades',
    require => Package['unattended-upgrades'],
  }
}
