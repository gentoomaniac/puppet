class hostbase::hostname(
  $hostname = $name,
) {
    exec { "set-hostname_${hostname}":
      command => "/usr/bin/hostnamectl set-hostname  ${hostname}",
      unless  => "/usr/bin/test $(hostnamectl hostname) = ${hostname}",
    }

    if $facts['networking']['fqdn'] != $hostname {
      host { "short_${facts['networking']['hostname']}":
        ensure  => absent,
        require => Exec["set-hostname_${hostname}"],
      }
      host { "fqdn_${facts['networking']['fqdn']}":
        ensure  => absent,
        require => Exec["set-hostname_${hostname}"],
      }
    }

    $alias = regsubst($name, '^([^.]*).*$', '\1')

    host { "lo_${hostname}":
      ensure  => present,
      ip      => '127.0.0.1',
      alias   => $alias,
      require => Exec["set-hostname_${hostname}"],
    }
}
