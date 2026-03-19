class hostbase::puppet (
) {

  $content = join(lookup('classes', Array[String], 'unique', []).sort, "\n")
  file { '/etc/puppet_classes':
    content => "${content}\n",
  }

  package { 'puppet':
    ensure => present,
  }

  service { 'puppet':
    ensure  => 'stopped',
    enable  => false,
    require => Package['puppet-agent'],
  }
}
