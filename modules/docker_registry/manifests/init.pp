# Class: docker_registry
#
#
class docker_registry (
  $labels = [],
) {
  file { '/srv/registry':
    ensure  => directory,
    require => File['/srv'],
    notify  => Docker::Run['registry'],
  }

  docker::run { 'registry':
    image            => 'registry:2',
    expose           => ['80/tcp'],
    env              => ['REGISTRY_HTTP_ADDR=0.0.0.0:80'],
    dns              => hiera('dns::servers'),
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/registry:/var/lib/registry'],
    require          => [Class['docker'], File['/srv/registry']],
  }
}
