class hostbase::puppet {

  if $facts['os']['architecture'] == 'amd64' {
    apt::key {'puppet6-gpg-key':
      id     => '7F438280EF8D349F',
      server => 'keyserver.ubuntu.com',
    }

    apt::source { 'puppet6':
      location => 'http://apt.puppetlabs.com',
      release  => $facts['os']['distro']['codename'],
      repos    => 'puppet6',
      require  => Apt::Key['puppet6-gpg-key'],
    }

    package { 'puppet-agent':
      ensure  => latest,
      require => Apt::Source['puppet6'],
    }
  }
  elsif $facts['os']['architecture'] == 'aarm64' {
    package{ 'ruby-full':
      ensure => latest,
    }

    package{ 'puppet':
      provider => 'puppet_gem',
      ensure   => 'latest',
      require  => Package['ruby-full'],
    }
  }

  vcsrepo { '/var/lib/puppet-repo':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/puppet.git',
    revision => $facts['puppet_branch'],
  }

  cron::job { 'puppet-cron':
    command     => 'puppet apply --config /var/lib/puppet-repo/puppet.conf -vt -l syslog /var/lib/puppet-repo/manifests/site.pp',
    minute      => '*/30',
    hour        => '*',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin:/opt/puppetlabs/bin"'],
    description => 'Run Puppet every 30 min',
    require     => [Package['puppet-agent'], Vcsrepo['/var/lib/puppet-repo']],
  }
}
