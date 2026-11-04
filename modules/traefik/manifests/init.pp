# Class: traefik
#
# Runs Traefik as a docker container on the `web` network (which the host has
# to create, e.g. via docker::networks) and manages its TLS files and dynamic
# configuration below /srv/traefik.
#
# @param certificates
#   TLS certificates by name. cert and key are hiera lookup keys of the PEM
#   contents. The default certificate is written to cert.pem/key.pem, all
#   others to <name>_cert.pem/<name>_key.pem.
# @param default_certificate
#   Name of the entry in $certificates used as Traefik's default store certificate.
# @param entrypoints
#   Additional entrypoints, name => address (e.g. websecure => ':443').
#   Router labels on other containers refer to these names.
# @param ports
#   Ports to publish in addition to the metrics (8080) and the localhost-only
#   dashboard (8081) ports.
# @param extra_args
#   Additional Traefik command line flags.
# @param dynamic_configs
#   Additional dynamic configuration files, file name => content, written to /srv/traefik/conf.
# @param version
#   Traefik image tag.
# @param env
#   Environment variables of the container.
class traefik (
  Hash[String, Struct[{ cert => String, key => String }]] $certificates,
  String $default_certificate,
  Hash[String, String] $entrypoints = {},
  Array[String] $ports = [],
  Array[String] $extra_args = [],
  Hash[String, String] $dynamic_configs = {},
  String $version = 'v3.6',
  Array[String] $env = ['TZ=Europe/Berlin'],
) {
  $base_dir = '/srv/traefik'

  btrfs::subvolume { $base_dir:
    ensure => present,
  }

  file { ["${base_dir}/conf", "${base_dir}/ssl"]:
    ensure  => directory,
    require => Btrfs::Subvolume[$base_dir],
  }

  # [certificate name, cert file name, key file name]
  $certificate_files = $certificates.map |$cert_name, $lookup_keys| {
    $prefix = $cert_name ? {
      $default_certificate => '',
      default              => "${cert_name}_",
    }
    $cert_file = "${prefix}cert.pem"
    $key_file = "${prefix}key.pem"

    file { "${base_dir}/ssl/${key_file}":
      ensure  => present,
      mode    => '0600',
      content => lookup($lookup_keys['key']),
      require => File["${base_dir}/ssl"],
      notify  => Docker::Run['traefik'],
    }
    file { "${base_dir}/ssl/${cert_file}":
      ensure  => present,
      mode    => '0644',
      content => lookup($lookup_keys['cert']),
      require => File["${base_dir}/ssl"],
      notify  => Docker::Run['traefik'],
    }

    [$cert_name, $cert_file, $key_file]
  }

  $ssl_files = $certificate_files.map |$entry| {
    [File["${base_dir}/ssl/${entry[1]}"], File["${base_dir}/ssl/${entry[2]}"]]
  }.flatten

  file { "${base_dir}/conf/certs.toml":
    ensure  => present,
    content => epp('traefik/certs.toml.epp', {
      default_cert => $certificate_files.filter |$entry| { $entry[0] == $default_certificate }[0],
      other_certs  => $certificate_files.filter |$entry| { $entry[0] != $default_certificate },
    }),
    require => $ssl_files + File["${base_dir}/conf"],
  }

  file { "${base_dir}/conf/dashboard.toml":
    ensure  => present,
    content => @(DASHBOARD),
      [http.routers.dashboard]
        rule = "PathPrefix(`/api`) || PathPrefix(`/dashboard`)"
        entryPoints = ["dashboard"]
        service = "api@internal"
      | DASHBOARD
    require => File["${base_dir}/conf"],
  }

  $dynamic_configs.each |$filename, $content| {
    file { "${base_dir}/conf/${filename}":
      ensure  => present,
      content => $content,
      require => File["${base_dir}/conf"],
    }
  }

  $entrypoint_args = $entrypoints.map |$entrypoint, $address| { "--entrypoints.${entrypoint}.address=${address}" }
  $args = [
    '--api.dashboard=true',
    '--entrypoints.traefik.address=:8080',
    '--entrypoints.dashboard.address=:8081',
    '--providers.docker',
    '--providers.docker.exposedbydefault=false',
    '--providers.file.directory=/conf',
    '--providers.file.watch=true',
    '--serverstransport.insecureskipverify=true',
    '--metrics.prometheus=true',
  ] + $entrypoint_args + $extra_args

  docker::run { 'traefik':
    service_provider => 'systemd',
    image            => "traefik:${version}",
    command          => join($args, ' '),
    ports            => [
      '8080:8080/tcp', # metrics, scraped by Prometheus
      '127.0.0.1:8081:8081/tcp', # dashboard, reach it via ssh -L 8081:localhost:8081
    ] + $ports,
    env              => $env,
    net              => ['web'],
    dns              => lookup('network::ipv4::dns::servers'),
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => [
      '/var/run/docker.sock:/var/run/docker.sock:ro',
      "${base_dir}/ssl:/ssl:ro",
      "${base_dir}/conf:/conf:ro",
    ],
    require          => [
      Class['docker'],
      Docker_network['web'],
      File["${base_dir}/conf/certs.toml"],
      File["${base_dir}/conf/dashboard.toml"],
      $ssl_files,
    ],
  }
}
