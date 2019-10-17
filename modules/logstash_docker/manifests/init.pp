# Class: coredns
#
#
class logstash_docker {
  file { '/srv/logstash':
    ensure  => directory,
    require => File['/srv'],
  }
  file { '/srv/logstash/pipelines':
    ensure  => directory,
    require => File['/srv/logstash'],
  }
  file { '/srv/logstash/config':
    ensure  => directory,
    require => File['/srv/logstash'],
  }

  docker::run { 'logstash':
    image            => 'docker.elastic.co/logstash/logstash:7.4.0',
    ports            => [],
    dns              => hiera('dns::servers'),
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/logstash:/usr/share/logstash/pipeline'],
    require          => Class['docker'],
  }

  file { '/srv/logstash/config/logstash.yml':
    ensure  => present,
    source  => 'puppet:///modules/logstash-docker/logstash.yml',
    require => File['/srv/logstash/config'],
    notify  => Docker::Run['logstash'],
  }
}
