define networkmanager::connection (
  String $interface = $title,
  
  Optional[Boolean] $activate = true,

  # IPv4 Configuration
  Enum['auto', 'manual', 'disabled'] $ipv4_method        = 'manual',
  Optional[Array[String]]            $ipv4_addresses     = undef,
  Optional[Integer]                  $ipv4_route_metric  = undef,
  Optional[Boolean]                  $ipv4_never_default = undef,

  Optional[String]                   $ipv4_gateway      = lookup('network::ipv4::gateway', Optional[String], 'first', undef),
  Optional[Array[String]]            $ipv4_dns          = lookup('network::ipv4::dns::servers', Optional[Array[String]], 'first', undef),
  Optional[Array[String]]            $ipv4_dns_search   = lookup('network::ipv4::dns::search', Optional[Array[String]], 'first', undef),

  # IPv6 Configuration
  Enum['ignore', 'auto', 'dhcp', 'manual', 'link-local'] $ipv6_method        = 'ignore',
  Optional[Array[String]]                                $ipv6_addresses     = undef,
  Optional[Integer]                                      $ipv6_route_metric  = undef,
  Optional[Boolean]                                      $ipv6_never_default = undef,

  Optional[String]                                       $ipv6_gateway      = lookup('network::ipv6::gateway', Optional[String], 'first', undef),
  Optional[Array[String]]                                $ipv6_dns          = lookup('network::ipv6::dns::servers', Optional[Array[String]], 'first', undef),
  Optional[Array[String]]                                $ipv6_dns_search   = lookup('network::ipv6::dns::search', Optional[Array[String]], 'first', undef),
) {

  file { "/etc/NetworkManager/system-connections/${interface}.nmconnection":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('networkmanager/connection.erb'),
    notify  => Exec['reload_nm_connections'],
  }

  if !defined(Exec['reload_nm_connections']) {
    exec { 'reload_nm_connections':
      command     => '/usr/bin/nmcli connection reload',
      refreshonly => true,
    }
  }

  if $activate {
    exec { "activate_nm_connection_${interface}":
      command     => "/usr/bin/nmcli connection up ${interface}",
      refreshonly => true,
      require     => Exec['reload_nm_connections'],
      subscribe   => File["/etc/NetworkManager/system-connections/${interface}.nmconnection"],
    }
  }
}
