class hostbase::puppet (
) {

  $content = join(lookup('classes', Array[String], 'unique', []).sort, "\n")
  file { '/etc/puppet_classes':
    content => "${content}\n",
  }

  stdlib::ensure_packages(['puppet'], {
    ensure => present,
  })

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
