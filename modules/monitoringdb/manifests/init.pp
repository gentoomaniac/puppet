# Class: monitoringdb
#
#
class monitoringdb {
  include ::java

  class { 'elasticsearch': }
  elasticsearch::instance { 'es-01': }
  elasticsearch::template { 'logstash_template':
    content => {
      'template' => 'logstash-*',
      'settings' => {
        'number_of_replicas' => 0,
      }
    }
  }
}
