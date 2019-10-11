# Class: coredns
#
#
class coredns {
  service { 'systemd-resolved':
    ensure => stopped,
    enable => false,
  }

  file { '/etc/resolv.conf':
    ensure  => file,
    content => 'puppet:///modules/coredns/resolv.conf',
    require => Service['systemd-resolved'],
  }

  file { '/opt/coredns':
    ensure => directory,
  }
  file { '/opt/coredns/Corefile':
    ensure  => file,
    content => 'puppet:///modules/coredns/Corefile',
    require => file['/opt/coredns'],
  }

  docker::run { 'coredns':
    image            => 'coredns/coredns:latest',
    ports            => ['53:53'],
    dns              => ['8.8.8.8', '8.8.4.4'],
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/opt/coredns:/data'],
    require          => [File['/opt/coredns/Corefile'],Service['systemd-resolved']],
  }
}
