class traefik (
  $args,
  $ports,
  $ssl_cert_location,
  $ssl_cert_name = 'fullchain1.pem',
  $ssl_key_name = 'privkey1.pem',
  $labels = [],
  $image = 'traefik',
  $tag = 'v2.2',
  $conf_dir = '/srv/traefik',
){

  file { '/srv/traefik':
    ensure  => directory,
    require => File['/srv'],
  }

  file { "${conf_dir}/certs.toml":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => epp('traefik/certs.toml.epp', {
      cert_path => '/ssl',
      cert_name => $ssl_cert_name,
      key_name  => $ssl_key_name,
    }),
    require => File['/srv/traefik'],
    notify  => Docker::Run['traefik'],
  }

  file { "${conf_dir}/static.toml":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/traefik/static.toml',
    require => File['/srv/traefik'],
    notify  => Docker::Run['traefik'],
  }

  docker_network { 'web':
    ensure => 'present',
  }

  docker::run { 'traefik':
    image            => "${image}:${tag}",
    command          => join($args, ' '),
    ports            => $ports,
    labels           => $labels,
    net              =>  ['web'],
    dns              => hiera('dns::servers'),
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/var/run/docker.sock:/var/run/docker.sock', "${ssl_cert_location}:/ssl:ro", "${conf_dir}:/conf:ro"],
    require          => [Class['docker'], Docker_network['web']],
  }
}
