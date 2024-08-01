define timer (
  $description,
  $unit,
  $on_boot,
  $on_calendar,
  $on_active,
  $on_inactive,
  $on_startup,
  $persistent = true,
) {

  file { 'timer':
    ensure  => file,
    path => "/etc/systemd/system/${name}.titmer",
    owner   => 'root',
    group   => 'root',
    content => epp('timer/timer.epp', {
      description => $description,
      unit  => $unit,
    }),
  }

  file { 'service':
    ensure  => file,
    command => "/etc/systemd/system/${name}.service",
    owner   => 'root',
    group   => 'root',
    content => epp('timer/service.epp', {
      description => $description,
      unit  => $unit,
    }),
  }

  exec{ 'systemd-reload':
    command => 'systemctl daemon-reload',
    refreshonly => true,
    path => ['/bin', '/usr/bin'],
    require => [File['service'], File['timer']]
  }

  service{ "${name}.time":
      ensure => running,
      enable => true,
      require => Exec['systemd-reload']
  }
}
