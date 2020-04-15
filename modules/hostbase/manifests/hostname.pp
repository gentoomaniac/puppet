class hostbase::hostname(
  $hostname = $name,
) {
    exec { 'set-hostname':
      command => "/usr/bin/hostnamectl set-hostname  ${hostname}",
      unless  => "/usr/bin/test $(hostname) = ${hostname}",
    }

    host { $::hostname:
        ensure  => absent,
        require => Exec['set-hostname'],
    }
    host { $::fqdn:
      ensure  => absent,
      require => Exec['set-hostname'],
    }

    $alias = regsubst($name, '^([^.]*).*$', '\1')

    host { $hostname:
        ensure  => present,
        ip      => $::ipaddress,
        alias   => $alias,
        require => Exec['set-hostname'],
    }

}
