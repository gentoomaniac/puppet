class hostbase::puppet (
  $version = latest,
) {

  $content = join(lookup('classes', Array[String], 'unique', []).sort, '\n')
  file { '/etc/puppet_classes':
    content => $content,
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
