class hostbase::packages (){
  $packages = lookup('hostbase::packages::present', Array[String], 'unique', [])
  stdlib::ensure_packages($packages, {
    ensure => latest,
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

  # TODO: build AUR for powerline-go
  # $powerlineVersion = '2.1.0'
  # $powerlineDebPath = "https://github.com/gentoomaniac/powerline-go/releases/download/v${powerlineVersion}"
  # $powerlineDebName = "powerline-go_${powerlineVersion}_linux_${facts['os']['architecture']}.deb"

  # file {"/var/tmp/${powerlineDebName}":
  #   ensure => 'present',
  #   source => "${powerlineDebPath}/${powerlineDebName}",
  # }
  # package { 'powerline-go-install':
  #   provider => dpkg,
  #   source   => "/var/tmp/${powerlineDebName}",
  # }
}
