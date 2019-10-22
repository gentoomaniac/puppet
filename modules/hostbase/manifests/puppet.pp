class hostbase::puppet (
  $version = latest,
) {

  file { '/etc/puppet_classes':
    content => lookup('classes', Array[String], 'unique', []).sort,
  }

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
