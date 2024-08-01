# Class: ioquake3
#
#
class ioquake3 (
  $labels = [],
) {
  file { '/srv/ioquake3':
    ensure  => directory,
    source  => 'puppet:///modules/ioquake3/cfg',
    recurse => 'true',
    require => File['/srv'],
    notify  => Docker::Run['ioquake3'],
  }

  docker::run { 'ioquake3':
    image            => 'ioquake3',
    command          => '/ioquake3/start_server.sh +exec server.cfg +exec ctf.cfg',
    ports            => ['27960:27960/udp'],
    dns              => lookup('dns::servers'),
    net              => ['web'],
    labels           => $labels,
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/ioquake3/server.cfg:/ioquake3/ioquake3/baseq3/server.cfg:ro',
                          '/srv/ioquake3/td.cfg:/ioquake3/ioquake3/baseq3/td.cfg:ro',
                          '/srv/ioquake3/ctf.cfg:/ioquake3/ioquake3/baseq3/ctf.cfg:ro'],
    require          => [Class['docker'], File['/srv/ioquake3']],
  }
}
