# Class: hostbase::disable_cloud
#
#
class hostbase::disable_cloud {
  exec { 'check_cloud_cfg':
    command => '/bin/true',
    onlyif  => '/usr/bin/test -d /etc/cloud',
  }

  file { '/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg':
    ensure  => file,
    content => 'network: {config: disabled}',
    require => Exec[check_cloud_cfg],
  }

  file { '/etc/cloud/cloud-init.disabled':
    ensure  => file,
    require => Exec[check_cloud_cfg],
  }
}
