class hostbase::sshd(
  $port = 22,
  $root_login_enable = true
) {

  # TODO: put the customisation into /etc/ssh/sshd_config.d
  file { '/etc/ssh/sshd_config':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => epp('hostbase/sshd_config.epp', {'port' => $port, 'root_login_enable' => $root_login_enable}),
  }

  service { 'sshd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['/etc/ssh/sshd_config'],
  }
}
