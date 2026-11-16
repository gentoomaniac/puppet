# @summary The containers this host should run, as metrics for the node-exporter textfile collector
#
# Writes `puppet_docker_container_expected{name} 1` for every container in
# docker::run_instance::instance (left out: `ensure: absent`, `running: false`)
# and every container a module declares with container_metrics::expected.
# Joined with cAdvisor's container_last_seen, a dashboard can show which of them
# are missing, and ignore one-off containers like certbot's or clouddns-updater's.
class container_metrics {
  include textfile_metrics

  $file = "${textfile_metrics::directory}/puppet_docker_containers.prom"

  concat { $file:
    ensure  => present,
    mode    => '0644',
    require => Class['textfile_metrics'],
  }

  concat::fragment { 'container_metrics header':
    target  => $file,
    order   => '00',
    content => @(HEADER),
      # HELP puppet_docker_container_expected Container this host should run, value is always 1.
      # TYPE puppet_docker_container_expected gauge
      | HEADER
  }

  lookup('docker::run_instance::instance', Hash, 'deep', {}).each |$title, $params| {
    if $params['ensure'] != 'absent' and $params['running'] != false {
      container_metrics::expected { $title: }
    }
  }
}
