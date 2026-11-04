# @summary journald size limit
class hostbase::journald {
  file { '/etc/systemd/journald.conf.d':
    ensure => directory,
  }

  file { '/etc/systemd/journald.conf.d/99-homelab.conf':
    ensure  => present,
    mode    => '0644',
    content => file('hostbase/journald-homelab.conf'),
    require => File['/etc/systemd/journald.conf.d'],
    notify  => Service['systemd-journald'],
  }

  service { 'systemd-journald':
    ensure => running,
  }
}
