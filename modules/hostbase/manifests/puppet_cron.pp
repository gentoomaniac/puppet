# @summary run-puppet from the homelab pacman repo, run every 30 minutes by a timer
#
# After each run, puppet-metrics exports Puppet's run summary (durations,
# resources changed/failed, events), /etc/puppet_branch and the applied commit
# to node-exporter.
class hostbase::puppet_cron {
  require hostbase::puppet
  include textfile_metrics

  # `puppet config print lastrunfile` for root
  $summary = '/opt/puppetlabs/puppet/public/last_run_summary.yaml'
  $metrics_file = "${textfile_metrics::directory}/puppet_last_run.prom"
  # confdir in puppet.conf: the checkout run-puppet applies
  $repo = '/var/lib/puppet-repo'

  file { '/usr/local/bin/puppet-metrics':
    ensure  => file,
    mode    => '0755',
    content => file('hostbase/puppet-metrics.rb'),
  }

  package { 'run-puppet':
    ensure => installed,
  }

  timer { 'run-puppet':
    description    => 'Execute run-puppet',
    # run-puppet >= 0.1.9 defaults to our otel endpoint and /usr/bin/puppet
    command        => '/usr/bin/run-puppet',
    on_calendar    => '*:0/30',
    # `-`: a metrics failure doesn't mark the run failed
    exec_stop_post => ["-/usr/local/bin/puppet-metrics ${summary} ${metrics_file} ${repo}"],
    require        => [Package['run-puppet'], File['/usr/local/bin/puppet-metrics']],
  }

  # binaries the hosts used to download from GitHub releases
  file { ['/usr/local/bin/run-puppet', '/usr/local/sbin/run-puppet', '/root/run-puppet_0.1.6_linux-amd64']:
    ensure  => absent,
    require => Timer['run-puppet'],
  }
}
