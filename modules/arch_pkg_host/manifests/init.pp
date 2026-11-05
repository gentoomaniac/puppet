# Class: arch_pkg_host
#
# Serves the homelab pacman repo from /srv/arch-pkg-host through nginx and Traefik,
# and builds it daily from PKGBUILDs in GitHub repos (see files/arch-repo-build.sh).
# The host only checks for new versions; builds run in a throwaway archlinux container
# that is started only when something needs building.
#
# @param labels
#   Traefik labels of the nginx container.
# @param build_repos
#   GitHub repo URLs (https://github.com/<owner>/<repo>) with a PKGBUILD at the root
#   of the default branch, built into the repo.
class arch_pkg_host (
  Array[String] $labels = [
    "traefik.enable=true",
    "traefik.http.routers.arch-pkg-host.rule=Host(`arch.srv.gentoomaniac.net`)",
    "traefik.http.routers.arch-pkg-host.entrypoints=ssl",
    "traefik.http.routers.arch-pkg-host.tls=true",
    "traefik.http.middlewares.arch-pkg-host-allowlist.ipallowlist.sourcerange=10.1.1.0/24,192.168.3.0/24,172.16.0.0/12",
    "traefik.http.routers.arch-pkg-host.middlewares=arch-pkg-host-allowlist",
  ],
  Array[Pattern[/\Ahttps?:\/\/github\.com\/[^\/\s]+\/[^\/\s]+\/?\z/]] $build_repos = [],
) {
  $repo_dir = '/srv/arch-pkg-host'
  $build_config = '/etc/arch-repo-build.conf'
  $build_script = '/usr/local/bin/arch-repo-build'

  btrfs::subvolume { $repo_dir:
    ensure => present,
  }

  docker::run { 'arch-pkg-host':
    service_provider => 'systemd',
    image            => 'nginx',
    expose           => ['80/tcp'],
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ["${repo_dir}:/usr/share/nginx/html:ro"],
    require          => [Class['docker'], Btrfs::Subvolume[$repo_dir]],
  }

  $config_lines = ['# MANAGED BY PUPPET: GitHub repos built into the homelab pacman repo'] + $build_repos
  file { $build_config:
    ensure  => file,
    mode    => '0644',
    content => "${config_lines.join("\n")}\n",
  }

  file { $build_script:
    ensure  => file,
    mode    => '0755',
    content => file('arch_pkg_host/arch-repo-build.sh'),
  }

  timer { 'arch-repo-build':
    description          => 'Build new package versions into the homelab pacman repo',
    command              => $build_script,
    group                => false,
    on_calendar          => 'daily',
    randomized_delay_sec => '1h',
    after                => ['docker.service', 'network-online.target'],
    wants                => ['network-online.target'],
    require              => [
      Class['docker'],
      Btrfs::Subvolume[$repo_dir],
      File[$build_config],
      File[$build_script],
    ],
  }
}
