class hostbase::sshd {
  file { '/etc/ssh/sshd_config':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0644,
    source => 'puppet:///modules/hostbase/sshd_config';
    notify => Service['sshd'],
  }

  service { "sshd":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}
