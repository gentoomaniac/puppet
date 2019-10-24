# Class: kickstart_nginx
#
#
class kickstart_nginx {
  file { '/srv/ksnginx':
    ensure  => directory,
    source  => 'puppet:///modules/kickstart_nginx/data',
    recurse => 'remote',
    require => File['/srv'],
    notify  => Docker::Run['ksnginx'],
  }

  docker::run { 'ksnginx':
    image            => 'nginx',
    expose           => ['80/tcp'],
    dns              => hiera('dns::servers'),
    labels           => [
      'traefik.backend=ksnginx',
      'traefik.port=80',
      'traefik.enable=true',
      'traefik.frontend.rule=Host:ks.srv.gentoomaniac.net',
      'traefik.passHostHeader=true',
      'traefik.frontend.whiteList.sourceRange=10.1.1.0/24,10.1.15.0/24',
    ],
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/ksnginx:/usr/share/nginx/html:ro'],
    require          => [Class['docker'], File['/srv/ksnginx']],
  }
}
