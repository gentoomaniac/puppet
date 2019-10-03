# Class: monitoringdb
#
#
class monitoringdb {
  include ::java

  class { 'elasticsearch':
    jvm_options => [
      '-Dfile.encoding=UTF-8',
      '-Dio.netty.noKeySetOptimization=true',
      '-Dio.netty.noUnsafe=true',
      '-Dio.netty.recycler.maxCapacityPerThread=0',
      '-Djava.awt.headless=true',
      '-Djna.nosys=true',
      '-Dlog4j.shutdownHookEnabled=false',
      '-Dlog4j2.disable.jmx=true',
      '-XX:+AlwaysPreTouch',
      '-XX:+HeapDumpOnOutOfMemoryError',
      '-XX:+PrintGCDetails',
      '-XX:+UseCMSInitiatingOccupancyOnly',
      '-XX:+UseConcMarkSweepGC',
      '-XX:-OmitStackTraceInFastThrow',
      '-XX:CMSInitiatingOccupancyFraction=75',
      '-Xloggc:/var/log/elasticsearch/es-01/gc.log',
      '-Xms2g',
      '-Xmx2g',
      '-Xss1m',
      '-server',
    ]
  }
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
