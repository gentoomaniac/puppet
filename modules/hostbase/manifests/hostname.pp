class hostbase::hostname (
  Stdlib::Fqdn $hostname,
) {
  exec { "set-hostname_${hostname}":
    command => "/usr/bin/hostnamectl set-hostname ${hostname}",
    unless  => "/usr/bin/test \"$(/usr/bin/hostnamectl hostname)\" = '${hostname}'",
  }

  # entries for the previous name after a rename
  if $facts['networking']['fqdn'] != $hostname {
    $old_names = [$facts['networking']['hostname'], $facts['networking']['fqdn']].unique.filter |$old| {
      $old =~ String and $old != $hostname and $old !~ /^localhost(\.|$)/
    }
    host { $old_names:
      ensure  => absent,
      require => Exec["set-hostname_${hostname}"],
    }
  }

  # left over from when the resource title was used as the host name
  host { "lo_${hostname}":
    ensure => absent,
  }

  host { $hostname:
    ensure       => present,
    ip           => '127.0.0.1',
    host_aliases => regsubst($hostname, '^([^.]*).*$', '\1'),
    require      => Exec["set-hostname_${hostname}"],
  }
}
