class hostbase::puppet_cron (
  $runPuppetVersion = '0.1.6',
) {
  require hostbase::puppet

  file { '/usr/local/bin/run-puppet':
    ensure => 'absent',
  }

  $runPuppetDebPath = "https://github.com/gentoomaniac/run-puppet/releases/download/v${runPuppetVersion}"
  $runPuppetDebName = "run-puppet_${runPuppetVersion}_linux_${facts['os']['architecture']}.deb"

  file {"/root/${runPuppetDebName}":
    ensure => 'present',
    source => "${runPuppetDebPath}/${runPuppetDebName}",
  }
  package { 'run-puppet-install':
    provider => dpkg,
    source   => "/root/${runPuppetDebName}",
  }

  file { '/etc/systemd/system/run-puppet.service':
    ensure  => 'present',
    mode    => '0644',
    source  => 'puppet:///modules/hostbase/puppet.service',
    require => File['/usr/local/bin/run-puppet'],
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
