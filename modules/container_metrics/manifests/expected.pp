# @summary A container this host should run, for container_metrics
#
# Declare it next to a docker::run that isn't in docker::run_instance::instance.
# The title is the docker::run title; it is sanitised the same way.
define container_metrics::expected {
  include container_metrics

  $name_label = docker::sanitised_name($title)

  concat::fragment { "container_metrics ${name_label}":
    target  => $container_metrics::file,
    order   => "10-${name_label}",
    content => "puppet_docker_container_expected{name=\"${name_label}\"} 1\n",
  }
}
