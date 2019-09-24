class hostbase::hosts{
  host { $::server_facts['servername']:
    ensure => present,
    ip     => $::server_factsp['serverip'],
  }
}
