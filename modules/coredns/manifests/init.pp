# Class: coredns
#
#
class coredns {
  btrfs::subvolume { '/srv/coredns':
    ensure => present,
  }
  file { '/srv/coredns/Corefile':
    ensure  => file,
    source  => 'puppet:///modules/coredns/Corefile',
    require => Btrfs::Subvolume['/srv/coredns'],
  }

  vcsrepo { '/srv/coredns/dnsdata':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dnsdata.git',
    revision => 'master',
    require => Btrfs::Subvolume['/srv/coredns'],
  }

  docker::run { 'coredns':
    image            => 'coredns/coredns',
    ports            => ['53:53', '53:53/udp', '9153:9153/tcp'],
    command          => '-conf /data/Corefile',
    dns              => ['8.8.8.8', '8.8.4.4'],
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/coredns:/data'],
    require          => [File['/srv/coredns/Corefile'],Vcsrepo['/srv/coredns/dnsdata']],
  }
}
