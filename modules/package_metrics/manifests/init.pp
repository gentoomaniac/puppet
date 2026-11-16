# @summary Installed pacman packages as metrics for the node-exporter textfile collector
#
# Writes `pacman_package_info{package,version} 1` for every installed package to
# `pacman_packages.prom` in the textfile_metrics directory. A pacman hook
# rewrites the file after every transaction; the exec recreates it when it's
# missing (first run, deleted).
class package_metrics {
  include textfile_metrics

  $script = '/usr/local/bin/package-metrics'
  $output = "${textfile_metrics::directory}/pacman_packages.prom"
  $command = "${script} ${output}"

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
    require => [File[$script], Class['textfile_metrics']],
  }
}
