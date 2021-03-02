class hostbase::puppet_cron {
  require hostbase::puppet

  file { '/usr/local/bin/run-puppet':
    ensure => 'present',
    mode   => '0744',
    source => 'puppet:///modules/hostbase/run-puppet.sh',
  }

  cron::job { 'puppet-cron':
    command     => '/usr/local/bin/run-puppet',
    minute      => '0',
    hour        => '2',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin:/opt/puppetlabs/bin"'],
    description => 'Run Puppet every 30 min',
    require     => File['/usr/local/bin/run-puppet'],
  }
}
