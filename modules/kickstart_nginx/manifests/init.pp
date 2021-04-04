# Class: kickstart_nginx
#
#
class kickstart_nginx (
  $labels = [],
) {
  file { '/srv/ksnginx':
    ensure  => directory,
    source  => 'puppet:///modules/kickstart_nginx/data',
    recurse => 'true',
    require => Zfs['datapool/ksnginx'],
    notify  => Docker::Run['ksnginx'],
  }

  docker::run { 'ksnginx':
    image            => 'nginx',
    expose           => ['80/tcp'],
    dns              => hiera('dns::servers'),
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/ksnginx:/usr/share/nginx/html:ro'],
    require          => [Class['docker'], File['/srv/ksnginx']],
  }
}
