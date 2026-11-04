# @summary mvault: vault wrapper that logs in with the host's AppRole credentials
class hostbase::vault {
  file { '/usr/local/bin/mvault':
    ensure  => present,
    mode    => '0754',
    content => file('hostbase/mvault.sh'),
    require => Package['vault'],
  }
}
