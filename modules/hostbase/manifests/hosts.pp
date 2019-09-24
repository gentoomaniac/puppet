class hostbase::hosts{
  host { $::facts['networking']['fqdn']:
    ensure => present,
    ip     => $::facts['networking']['ip'],
  }
}
