class hostbase::puppet_cron {
  require hostbase:puppet

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
    require     => Vcsrepo['/var/lib/puppet-repo'],
  }
}
