# Class: monitoringdb
#
#
class monitoringdb {
  include ::java

  apt::key {'elasticsearch-key':
    id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
    server => 'keyserver.ubuntu.com',
  }

  apt::source { 'elasticsearch-7':
    location => 'https://artifacts.elastic.co/packages/7.x/apt',
    release  => 'stable',
    repos    => 'main',
    require  => Apt::Key['elasticsearch-key'],
  }

  package { 'elasticsearch':
    ensure  => $version,
    require => Apt::Source['elasticsearch-7'],
  }

  #service { 'elasticsearch':
  #  ensure  => 'stopped',
  #  enable  => false,
  #  require => Package['elasticsearch'],
  #}
}
