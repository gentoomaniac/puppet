# Class: tftpd
#
#
class tftpd {

  file { '/srv/tftpd':
    ensure  => directory,
    source  => 'puppet:///modules/tftpd/data',
    recurse => 'remote',
    require => File['/srv'],
    notify  => Docker::Run['tftpd'],
  }

  docker::run { 'tftpd':
    image            => 'pghalliday/tftp',
    ports            => ['69:69/udp'],
    dns              => hiera('dns::servers'),
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/tftpd:/var/tftpboot:ro'],
    require          => [Class['docker'], File['/srv/tftpd']],
  }
}
