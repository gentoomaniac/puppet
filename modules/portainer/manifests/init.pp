# Class: portainer
#
#
class portainer (
  $labels = [],
) {
  file { '/srv/portainer':
    ensure  => directory,
    require => File['/srv'],
    notify  => Docker::Run['portainer'],
  }

  docker::run { 'portainer':
    image            => 'portainer/portainer',
    command          => '-H unix:///var/run/docker.sock',
    expose           => ['9000/tcp'],
    dns              => hiera('dns::servers'),
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/portainer:/config', '/var/run/docker.sock:/var/run/docker.sock'],
    require          => [Class['docker'], File['/srv/portainer']],
  }
}
