# Class: hostbase::metricbeat
#
class hostbase::metricbeat (
  $version = latest,
){
  package { 'metricbeat':
    ensure  => $version,
    require => Apt::Source['elasticsearch7x'],
  }

  file { '/etc/metricbeat/metricbeat.yml':
    ensure  => file,
    mode    => '0600',
    source  => 'puppet:///modules/hostbase/metricbeat/metricbeat.yml',
    require => Package['metricbeat'],
    notify  => Service['metricbeat-svc']
  }

  file { '/etc/metricbeat/modules.d/system.yml':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/hostbase/metricbeat/system.yml',
    require => Package['metricbeat'],
  }

  service { 'metricbeat-svc':
    ensure     => running,
    name       => 'metricbeat',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }
}
