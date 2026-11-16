# @summary The directory node-exporter's textfile collector reads metrics from
#
# Modules that export metrics `include textfile_metrics` and write `*.prom`
# files to `$textfile_metrics::directory`. node-exporter sees it through its
# /host mount of the root filesystem (--collector.textfile.directory in
# hiera/hostbase.yaml).
#
# @param directory The textfile directory.
class textfile_metrics (
  Stdlib::Absolutepath $directory = '/var/lib/node_exporter/textfile',
) {
  file { [dirname($directory), $directory]:
    ensure => directory,
    mode   => '0755',
  }
}
