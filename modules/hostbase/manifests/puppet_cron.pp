class hostbase::puppet_cron (
  $runPuppetVersion = '0.1.6',
) {
  require hostbase::puppet

  file { '/usr/local/bin/run-puppet':
    ensure => 'absent',
  }

  $runPuppetDebPath = "https://github.com/gentoomaniac/run-puppet/releases/download/v${runPuppetVersion}"
  $runPuppetFileName = "run-puppet_${runPuppetVersion}_linux-amd64"

  file {"/root/${runPuppetFileName}":
    ensure => 'present',
    source => "${runPuppetDebPath}/${runPuppetFileName}",
  }
  file {"/usr/local/sbin/run-puppet":
    ensure => 'present',
    source => "${runPuppetDebPath}/${runPuppetFileName}",
    owner  => 'root',
    group  => 'root',
    mode   => '0744',
    require => File["/root/${runPuppetFileName}"],
  }

  timer { 'run-puppet':
    description => 'Execute run-puppet',
    command     => '/usr/local/sbin/run-puppet --otel-endpoint-url=https://otelcol.srv.gentoomaniac.net:4318 --bin-path /usr/bin/puppet',
    on_calendar => '*:0/30',
    require     => File['/usr/local/sbin/run-puppet'],
  }
}
