class hostbase::packages (){
  $packages = lookup('hostbase::packages::present', Array[String], 'unique', [])
  stdlib::ensure_packages($packages, {
    ensure => installed,
  })

  $remove = lookup({
    'name'          => 'hostbase::packages::absent',
    'value_type'    => Array[String],
    'merge'         => 'unique',
    'default_value' => [],
  })
  stdlib::ensure_packages($remove, {
    ensure => absent,
  })
}
