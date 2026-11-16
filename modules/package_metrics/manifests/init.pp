# @summary Installed pacman packages as metrics for the node-exporter textfile collector
#
# Writes `pacman_package_info{package,version} 1` for every installed package to
# `<textfile_dir>/pacman_packages.prom`. A pacman hook rewrites the file after
# every transaction; the exec recreates it when it's missing (first run, deleted).
#
# @param textfile_dir Directory node-exporter reads with --collector.textfile.directory
#   (seen through its /host mount of the root filesystem).
class package_metrics (
  Stdlib::Absolutepath $textfile_dir = '/var/lib/node_exporter/textfile',
) {
  $script = '/usr/local/bin/package-metrics'
  $output = "${textfile_dir}/pacman_packages.prom"
  $command = "${script} ${output}"

  file { ['/var/lib/node_exporter', $textfile_dir]:
    ensure => directory,
    mode   => '0755',
  }

  file { $script:
    ensure  => file,
    mode    => '0755',
    content => file('package_metrics/package-metrics.sh'),
  }

  file { '/etc/pacman.d/hooks':
    ensure => directory,
  }

  file { '/etc/pacman.d/hooks/package-metrics.hook':
    ensure  => file,
    mode    => '0644',
    content => epp('package_metrics/package-metrics.hook.epp', { 'command' => $command }),
    require => [File['/etc/pacman.d/hooks'], File[$script]],
  }

  exec { 'package-metrics':
    command => $command,
    creates => $output,
    path    => ['/usr/bin', '/usr/local/bin'],
    require => [File[$script], File[$textfile_dir]],
  }
}
