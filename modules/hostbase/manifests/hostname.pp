class hostbase::hostname(
  $hostname = $name,
) {
    exec { 'set-hostname':
      command => "/usr/bin/hostnamectl set-hostname  ${hostname}",
      unless  => "/usr/bin/test $(hostname) = ${hostname}",
    }

    if $::fqdn != $hostname {
      host { $::hostname:
        ensure  => absent,
        require => Exec['set-hostname'],
      }
      host { $::fqdn:
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
