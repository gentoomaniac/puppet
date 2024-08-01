class hostbase::sshd {

  if $facts['os']['distro']['codename'] == "noble" {
    $service_name = "ssh"
  } else {
    $service_name = "sshd"
  }

  file { '/etc/ssh/sshd_config':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/hostbase/sshd_config',
  }

  service { $service_name:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['/etc/ssh/sshd_config'],
  }
}
