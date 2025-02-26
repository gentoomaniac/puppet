class hostbase::cleanup(){

  docker::run { 'openhab':
    ensure => absent,
  }

}
