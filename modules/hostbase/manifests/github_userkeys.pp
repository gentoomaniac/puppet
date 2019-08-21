class hostbase::github_userkeys (
  $localuser = $name,
  $githubaccount,
){
  file { '/etc/userkeys/${localuser}':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0755,
  }
  file { "/etc/userkeys/${localuser}/authorized_keys":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0644,
    source => 'https://github.com/${githubaccount}.keys',
  }
}
