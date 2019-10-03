# Class: monitoringdb
#
#
class monitoringdb {
  include ::java

  class { 'elasticsearch': }
  elasticsearch::instance { 'es-01':
    restart_on_change => true,
  }
  elasticsearch::template { 'logstash_template':
  content => {
    'template' => 'logstash-*',
    'settings' => {
      'number_of_replicas' => 0,
    }
  }
}
