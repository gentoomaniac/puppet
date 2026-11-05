# @summary run-puppet from the homelab pacman repo, run every 30 minutes by a timer
class hostbase::puppet_cron {
  require hostbase::puppet

  package { 'run-puppet':
    ensure => installed,
  }

  timer { 'run-puppet':
    description => 'Execute run-puppet',
    command     => '/usr/bin/run-puppet --otel-endpoint-url=https://otelcol.srv.gentoomaniac.net:4318 --bin-path /usr/bin/puppet',
    on_calendar => '*:0/30',
    require     => Package['run-puppet'],
  }

  # binaries the hosts used to download from GitHub releases
  file { ['/usr/local/bin/run-puppet', '/usr/local/sbin/run-puppet', '/root/run-puppet_0.1.6_linux-amd64']:
    ensure  => absent,
    require => Timer['run-puppet'],
  }
}
