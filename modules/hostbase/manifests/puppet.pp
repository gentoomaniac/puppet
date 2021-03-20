class hostbase::puppet (
  $version = latest,
) {

  $content = join(lookup('classes', Array[String], 'unique', []).sort, "\n")
  file { '/etc/puppet_classes':
    content => "${content}\n",
  }

  package { 'puppet':
    ensure => absent,
  }

  package { 'puppet7-release':
    ensure => present,
  }

  package { 'puppet-agent':
    ensure  => $version,
    mark    => hold,
    require => [Package['puppet7-release'], Package['puppet'], Class['Apt::Update']],
  }

  service { 'puppet':
    ensure  => 'stopped',
    enable  => false,
    require => Package['puppet-agent'],
  }
}
