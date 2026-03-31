# Class: arch_pkg_host
#
#
class arch_pkg_host (
  $labels = [
    "traefik.enable=true",
    "traefik.http.routers.arch-pkg-host.rule=Host(`arch.srv.gentoomaniac.net`)",
    "traefik.http.routers.arch-pkg-host.entrypoints=ssl",
    "traefik.http.routers.arch-pkg-host.tls=true",
    "traefik.http.middlewares.arch-pkg-host-whitelist.ipwhitelist.sourcerange=10.1.1.0/24,192.168.3.0/24,172.0.0.0/8",
    "traefik.http.routers.arch-pkg-host.middlewares=arch-pkg-host-whitelist",
  ],
) {

  btrfs::subvolume { '/srv/arch-pkg-host':
    ensure => present,
  }

  docker::run { 'arch-pkg-host':
    service_provider => 'systemd',
    image            => 'nginx',
    expose           => ['80/tcp'],
    dns              => lookup('network::ipv4::dns::servers'),
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/arch-pkg-host:/usr/share/nginx/html:ro'],
    require          => [Class['docker'], File['/srv/arch-pkg-host']],
  }
}
