class hostbase::syslog {
  package { 'rsyslog-pkg':
    ensure => latest,
    name   => 'rsyslog',
  }

  if $facts['os']['name'] == 'Ubuntu' {
    file_line { 'syslog_timestamp_format':
      ensure  => present,
      path    => '/etc/rsyslog.conf',
      line    => 'ActionFileDefaultTemplate RSYSLOG_FileFormat',
      match   => '^#?ActionFileDefaultTemplate .*$',
      require => Package['rsyslog-pkg'],
      notify  => Service['rsyslog-svc'],
    }
  }

  service{'rsyslog-svc':
    ensure    => running,
    name      => 'rsyslog',
    enable    => true,
    hasstatus => true,
  }

  file{'/usr/local/bin/syslog2elastic.py':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/hostbase/syslog2elastic.py',
  }
}
