# Class: tautulli
#
#
class tautulli (
  $labels = [],
) {
  file { '/srv/tautulli':
    ensure  => directory,
    require => File['/srv'],
    notify  => Docker::Run['tautulli'],
  }

  docker::run { 'tautulli':
    image            => 'linuxserver/tautulli',
    expose           => ['8181/tcp'],
    env              => ['PUID=1000', 'PGID=1000', 'TZ=Europe/Berlin'],
    dns              => hiera('dns::servers'),
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/tautulli:/config'],
    require          => [Class['docker'], File['/srv/ksnginx']],
  }
}
