class hostbase::puppet (
  $version = latest,
  $release = 'puppet8-release',
) {

  $content = join(lookup('classes', Array[String], 'unique', []).sort, "\n")
  file { '/etc/puppet_classes':
    content => "${content}\n",
  }

  package { 'puppet':
    ensure => absent,
  }

  package { $release:
    ensure => present,
  }

  $rubydeps = ['vault', 'debouncer']
  package {$rubydeps:
    ensure   => present,
    provider => 'puppet_gem',
    require  => Package['puppet'],
  }

  package { 'puppet-agent':
    ensure  => "${version}${facts['os']['distro']['codename']}",
    mark    => hold,
    require => [Package[$release], Package['puppet'], Class['Apt::Update']],
  }

  service { 'puppet':
    ensure  => 'stopped',
    enable  => false,
    require => Package['puppet-agent'],
  }
}
