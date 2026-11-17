# @summary Docker daemon configuration
#
# @param dns_servers Resolvers handed to every container, so containers don't
#   need a per-container dns setting.
class hostbase::docker (
  Array[String[1]] $dns_servers = lookup('network::ipv4::dns::servers'),
) {
  file { '/etc/docker':
    ensure => directory,
  }

  file { '/etc/docker/daemon.json':
    ensure  => present,
    mode    => '0644',
    content => epp('hostbase/daemon.json.epp', { dns_servers => $dns_servers }),
    require => [File['/etc/docker'], Package['docker']],
    notify  => Service['docker'],
  }
}
