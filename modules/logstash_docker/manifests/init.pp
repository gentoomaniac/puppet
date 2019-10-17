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
    ports            => ['5044:5044/tcp', '9600:9600/tcp'],
    dns              => hiera('dns::servers'),
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ['/srv/logstash/pipeline:/usr/share/logstash/pipeline', '/srv/logstash/config:/usr/share/logstash/config'],
    require          => [Class['docker'], File['/srv/logstash/config/logstash.yml']],
  }

  file { '/srv/logstash/config/logstash.yml':
    ensure  => present,
    source  => 'puppet:///modules/logstash_docker/logstash.yml',
    require => File['/srv/logstash/config'],
    notify  => Docker::Run['logstash'],
  }
}
