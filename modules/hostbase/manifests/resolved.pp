# Class: hostbase:
#
class hostbase::resolved {
  service { 'systemd-resolved':
    ensure => stopped,
    enable => false,
  }

  file { '/etc/resolv.conf':
    ensure  => file,
    source  => 'puppet:///modules/hostbase/resolv.conf',
    require => Service['systemd-resolved'],
  }
}
