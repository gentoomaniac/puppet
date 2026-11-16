# @summary timer-metrics: the ExecStopPost that exports each timer run to node-exporter
#
# Included by every `timer` with `metrics => true`; see timer-metrics.sh for the metrics.
class timer::metrics {
  include textfile_metrics

  file { '/usr/local/bin/timer-metrics':
    ensure  => file,
    mode    => '0755',
    content => file('timer/timer-metrics.sh'),
  }
}
