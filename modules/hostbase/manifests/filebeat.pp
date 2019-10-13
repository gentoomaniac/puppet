# Class: hostbase::filebeat
#
#
class hostbase::filebeat (
  $version = latest,
){
  package { 'filebeat':
    ensure  => $version,
    require => Apt::Source['elasticsearch7x'],
  }

  file { '/etc/filebeat/filebeat.yml':
    ensure  => file,
    mode    => '0600',
    source  => 'puppet:///modules/hostbase/filebeat/filebeat.yml',
    require => Package['filebeat'],
    notify  => Service['filebeat-svc']
  }

  service { 'filebeat-svc':
    ensure     => running,
    name       => 'filebeat',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}
