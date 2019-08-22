class hostbase::github_userkeys {
  file{ '/etc/userkeys':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  lookup('github_userkeys').each |String $localuser, String $githubaccount| {
    file { "/etc/userkeys/${localuser}":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0755',
      require => File['/etc/userkeys'],
    }
    file { "/etc/userkeys/${localuser}/authorized_keys":
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0644',
      source => "https://github.com/${githubaccount}.keys",
    }
  }
}
