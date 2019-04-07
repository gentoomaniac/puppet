class hostbase::packages (
  $base_packages = [],
){
  package { $base_packages :
    ensure => latest,
  }
}
