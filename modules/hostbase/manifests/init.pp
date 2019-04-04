class hostbase {
  $packages = ['docker-compose']

  package{ $packages :
    ensure  => latest,
  }

}
