class hostbase::packages (){
  $packages = lookup('hostbase::packages::base_packages', Array[String], 'unique')
  package { $packages :
    ensure => latest,
  }
}
