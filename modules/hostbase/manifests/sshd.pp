class hostbase::sshd(
  $port = 22,
  $root_login_enable = true
) {

  if $facts['os']['distro']['codename'] == 'noble' {
    $service_name = 'ssh'
  } else {
    $service_name = 'sshd'
  }

  file { '/etc/ssh/sshd_config':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp('hostbase/sshd_config.epp', {'port' => $port, 'root_login_enable' => $root_login_enable}),
  }

  service { $service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['/etc/ssh/sshd_config'],
  }
}
