# Class: coredns
#
#
class coredns {
  zfs { 'datapool/coredns':
    ensure => present,
  }
  file { '/srv/coredns/Corefile':
    ensure  => file,
    source  => 'puppet:///modules/coredns/Corefile',
    require => Zfs['datapool/coredns'],
    notify  => Docker::Run['coredns'],
  }

  vcsrepo { '/srv/coredns/dnsdata':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dnsdata.git',
    revision => 'master',
    notify   => Docker::Run['coredns'],
  }

  docker::run { 'coredns':
    image            => 'coredns/coredns',
    ports            => ['53:53', '53:53/udp', '9153:9153/tcp'],
    command          => '-conf /data/Corefile',
    dns              => ['8.8.8.8', '8.8.4.4'],
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/coredns:/data'],
    require          => [File['/srv/coredns/Corefile'],Service['systemd-resolved'], Vcsrepo['/srv/coredns/dnsdata'], Class['docker']],
  }
}
