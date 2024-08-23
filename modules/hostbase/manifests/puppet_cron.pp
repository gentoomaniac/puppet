class hostbase::puppet_cron {
  require hostbase::puppet

  file { '/usr/local/bin/run-puppet':
    ensure => 'present',
    mode   => '0744',
    source => 'puppet:///modules/hostbase/run-puppet.sh',
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
