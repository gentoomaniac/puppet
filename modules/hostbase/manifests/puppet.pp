  class hostbase::puppet {
    apt::key {'puppet6-gpg-key':
      id      => '8735F5AF62A99A628EC13377B8F999C007BB6C57',
      server  => 'pgp.mit.edu',
    }

    apt::source { 'puppet6':
      location     => ' http://apt.puppetlabs.com',
      release      => $facts['os']['distro']['codename'],
      repos        => 'puppet6',
      require      => Apt::Key['puppet6-gpg-key'],
    }

    package { 'puppet-agent':
      ensure => latest,
    }

    cron::job { 'puppet-cron':
      command      => 'puppet apply --config /home/marco/git/puppet/puppet.conf -vt -l syslog /home/marco/git/puppet/manifests/site.pp',
      minute       => '*/30',
      hour         => '*',
      date         => '*',
      month        => '*',
      weekday      => '*',
      user         => 'root',
      environment  => ['MAILTO=root', 'PATH="/usr/bin:/bin:/opt/puppetlabs/bin"'],
      description  => 'Run Puppet every 30 min',
      require      => Package['puppet-agent'],
    }
  }
