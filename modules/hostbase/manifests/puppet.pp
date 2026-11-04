class hostbase::puppet (
) {

  $content = join(lookup('classes', Array[String], 'unique', []).sort, "\n")
  file { '/etc/puppet_classes':
    content => "${content}\n",
  }

  stdlib::ensure_packages(['puppet'], {
    ensure => present,
  })

  # Gems of the hiera_vault backend, loaded by the ruby puppet runs on. That is
  # Arch's system ruby, not the puppet-agent AIO one, so the `puppet_gem`
  # provider (confined to AIO, targets /opt/puppetlabs/puppet/bin/gem) doesn't
  # apply and the plain `gem` provider installs into the right gem path.
  # The titles are prefixed because Package[vault] is the pacman package.
  ['vault', 'debouncer', 'toml-rb'].each |$gem| {
    package { "gem-${gem}":
      ensure   => installed,
      name     => $gem,
      provider => gem,
      require  => Package['puppet'],
    }
  }

  # Vault AppRole credentials written by bootstrap.sh. No ensure: only fix
  # ownership and mode where they exist, never create empty ones.
  file { ['/etc/vault_role_id', '/etc/vault_secret_id', '/etc/vault_token']:
    owner => 'root',
    group => 'root',
    mode  => '0600',
  }

  service { 'puppet':
    ensure  => 'stopped',
    enable  => false,
    require => Package['puppet'],
  }
}
