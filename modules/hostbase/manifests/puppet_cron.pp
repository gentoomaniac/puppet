class hostbase::puppet_cron (
  $runPuppetVersion = '0.1.6',
) {
  require hostbase::puppet

  file { '/usr/local/bin/run-puppet':
    ensure => 'absent',
  }

  $runPuppetDebPath = "https://github.com/gentoomaniac/run-puppet/releases/download/v${runPuppetVersion}"
  $runPuppetFileName = "run-puppet_${runPuppetVersion}_linux_${facts['os']['architecture']}"

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

  file { '/etc/systemd/system/run-puppet.service':
    ensure  => 'present',
    mode    => '0644',
    source  => 'puppet:///modules/hostbase/puppet.service',
    require => File['/usr/local/sbin/run-puppet'],
  }

  file { '/etc/systemd/system/run-puppet.timer':
    ensure  => 'present',
    mode    => '0644',
    source  => 'puppet:///modules/hostbase/puppet.timer',
    require => File['/etc/systemd/system/run-puppet.service'],
  }

  service { 'run-puppet.timer':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/run-puppet.timer'],
  }
}
