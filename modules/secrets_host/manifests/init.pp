class secrets_host {
  file { '/tmp/testfile':
    ensure  => 'present',
    content => vault_lookup::lookup('secret/data/roles/nzbget/somesecret/secret', 'https://vault.srv.gentoomaniac.net'),
  }
}
