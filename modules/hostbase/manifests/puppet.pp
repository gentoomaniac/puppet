# @summary Puppet itself: the openvox package, hiera_vault gems and credentials.
#
# Arch's `puppet` package stopped at 8.10; `openvox` is the maintained drop-in
# replacement (same /usr/bin/puppet, same puppet.service). Hosts still on the
# old package are switched out of band, see switch-to-openvox.sh.
class hostbase::puppet {
  $content = join(lookup('classes', Array[String], 'unique', []).sort, "\n")
  file { '/etc/puppet_classes':
    content => "${content}\n",
  }

  if $facts['puppet_package'] == 'openvox' {
    stdlib::ensure_packages(['openvox'], {
      ensure => present,
    })
    $puppet_package = Package['openvox']

    file { '/usr/local/sbin/switch-to-openvox':
      ensure => absent,
    }
  } else {
    # TEMPORARY: remove this branch (and switch-to-openvox.sh) once every host runs openvox.
    # Puppet can't replace its own package mid-run, and the pacman provider's
    # --noconfirm declines the conflict removal, so a transient unit does it
    # after this run has finished.
    file { '/usr/local/sbin/switch-to-openvox':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/hostbase/switch-to-openvox.sh',
    }

    exec { 'switch-to-openvox':
      command => '/usr/bin/systemd-run --unit=switch-to-openvox --collect /usr/local/sbin/switch-to-openvox',
      unless  => '/usr/bin/systemctl is-active --quiet switch-to-openvox.service',
      require => File['/usr/local/sbin/switch-to-openvox'],
    }
    $puppet_package = undef
  }

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
      require  => $puppet_package,
    }
  }

  # Vault AppRole credentials written by bootstrap.sh. No ensure: only fix
  # ownership and mode where they exist, never create empty ones.
  file { ['/etc/vault_role_id', '/etc/vault_secret_id', '/etc/vault_token']:
    owner => 'root',
    group => 'root',
    mode  => '0600',
  }

  # run-puppet.timer runs `puppet apply`; the agent daemon stays off
  service { 'puppet':
    ensure  => 'stopped',
    enable  => false,
    require => $puppet_package,
  }
}
