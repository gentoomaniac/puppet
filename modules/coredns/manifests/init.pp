# Class: coredns
#
#
class coredns {
  file { '/opt/coredns':
    ensure => directory,
  }
  file { '/opt/coredns/Corefile':
    ensure  => file,
    source  => 'puppet:///modules/coredns/Corefile',
    require => File['/opt/coredns'],
  }

  vcsrepo { '/opt/coredns/dnsdata':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dnsdata.git',
    revision => 'master',
    notify   => [Docker::Run['coredns']],
  }

  docker::run { 'coredns':
    image            => 'coredns/coredns:latest',
    ports            => ['53:53', '53:53/udp', '9153:9153/tcp'],
    command          => '-conf /data/Corefile',
    dns              => ['8.8.8.8', '8.8.4.4'],
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/opt/coredns:/data'],
    require          => [File['/opt/coredns/Corefile'],Service['systemd-resolved'], Vcsrepo['/opt/coredns/dnsdata'], Class['docker']],
  }

  file { '/etc/metricbeat/modules.d/coredns.yml':
    ensure  => present,
    source  => 'puppet:///modules/coredns/metricbeat.coredns.yml',
    require => Package['metricbeat'],
    notify  => Service['metricbeat-svc'],
  }
}
