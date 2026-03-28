# Class: kickstart_nginx
#
#
class kickstart_nginx (
  $labels = [],
) {

  btrfs::subvolume { '/srv/ksnginx':
    ensure => present,
  }

  file { '/srv/ksnginx':
    ensure  => directory,
    source  => 'puppet:///modules/kickstart_nginx/data',
    recurse => 'true',
    require => Btrfs::Subvolume['/srv/ksnginx'],
    notify  => Docker::Run['ksnginx'],
  }

  docker::run { 'ksnginx':
    service_provider => 'systemd',
    image            => 'nginx',
    expose           => ['80/tcp'],
    dns              => lookup('network::ipv4::dns::servers'),
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/ksnginx:/usr/share/nginx/html:ro'],
    require          => [Class['docker'], File['/srv/ksnginx']],
  }
}
