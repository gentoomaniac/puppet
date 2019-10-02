class hostbase::hosts{
  file_line { "hosts.${::facts['networking']['fqdn']}":
    ensure => 'present',
    path   => '/etc/hosts',
    match  => "^${::facts['networking']['ip']}.*",
    line   => "${::facts['networking']['ip']} ${::facts['networking']['fqdn']}",
  }
}
