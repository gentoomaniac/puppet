# @summary custom-metrics: prints pending updates and the puppet branch in line protocol
class hostbase::metrics {
  file { '/usr/local/bin/custom-metrics':
    ensure  => present,
    mode    => '0755',
    content => file('hostbase/custom-metrics.sh'),
    require => [Package['arch-audit'], Package['lsb-release']],
  }
}
