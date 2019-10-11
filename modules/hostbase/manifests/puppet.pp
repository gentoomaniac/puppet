class hostbase::puppet (
  $version = latest,
) {

  package { 'puppet':
    ensure => absent,
  }

  package { 'puppet-agent':
    ensure  => $version,
    require => [Apt::Source['puppet6'],Package['puppet']],
  }

  service { 'puppet':
    ensure  => 'stopped',
    enable  => false,
    require => Package['puppet-agent'],
  }
}
