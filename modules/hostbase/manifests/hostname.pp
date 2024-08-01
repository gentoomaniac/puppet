class hostbase::hostname(
  $hostname = $name,
) {
    exec { 'set-hostname':
      command => "/usr/bin/hostnamectl set-hostname  ${hostname}",
      unless  => "/usr/bin/test $(hostname) = ${hostname}",
    }

    if $facts['networking']['fqdn'] != $hostname {
      host { $facts['networking']['hostname']:
        ensure  => absent,
        require => Exec['set-hostname'],
      }
      host { $facts['networking']['fqdn']:
        ensure  => absent,
        require => Exec['set-hostname'],
      }
    }

    $alias = regsubst($name, '^([^.]*).*$', '\1')

    host { $hostname:
      ensure  => present,
      ip      => '127.0.0.1',
      alias   => $alias,
      require => Exec['set-hostname'],
    }
}
