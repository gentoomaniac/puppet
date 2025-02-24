class hostbase::packages (){
  $packages = lookup('hostbase::packages::present', Array[String], 'unique')
  package { $packages :
    ensure => latest,
  }

  $remove = lookup('hostbase::packages::absent', Array[String], 'unique')
  package { $remove :
    ensure => absent,
  }


  $powerlineVersion = '2.1.0'
  $powerlineDebPath = "https://github.com/gentoomaniac/powerline-go/releases/download/v${powerlineVersion}"
  $powerlineDebName = "powerline-go_${powerlineVersion}_linux_${facts['os']['architecture']}.deb"

  file {"/var/tmp/${powerlineDebName}":
    ensure => 'present',
    source => "${powerlineDebPath}/${powerlineDebName}",
  }
  package { 'powerline-go-install':
    provider => dpkg,
    source   => "/var/tmp/${powerlineDebName}",
  }
}
