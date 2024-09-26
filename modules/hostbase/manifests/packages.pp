class hostbase::packages (){
  $packages = lookup('hostbase::packages::present', Array[String], 'unique')
  package { $packages :
    ensure => latest,
  }

  $remove = lookup('hostbase::packages::absent', Array[String], 'unique')
  package { $remove :
    ensure => absent,
  }
}
