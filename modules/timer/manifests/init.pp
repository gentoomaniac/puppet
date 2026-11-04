# @summary A systemd timer plus the oneshot service it triggers.
#
# Writes /etc/systemd/system/<title>.service and <title>.timer and keeps the
# timer enabled and running. Changes to either unit restart the timer; the
# systemd service provider runs daemon-reload first when needed.
#
# @example From hiera via the `resources` hash
#   resources:
#     timer:
#       paccache-cleanup:
#         description: paccache cleanup
#         command: /usr/local/bin/paccache-cleanup
#         on_calendar: Sun *-*-* 03:00:00
#         randomized_delay_sec: 1h
#
# @param description Description for both units.
# @param command ExecStart of the service.
# @param on_calendar OnCalendar expression(s).
# @param on_boot_sec OnBootSec.
# @param on_unit_active_sec OnUnitActiveSec.
# @param randomized_delay_sec RandomizedDelaySec.
# @param persistent Catch up on runs missed while the machine was off.
# @param user User the service runs as.
# @param group Group the service runs as; `false` omits Group=.
# @param after Units the service starts after.
# @param wants Units the service wants.
# @param ensure `absent` stops the timer and removes both units.
define timer (
  String[1] $description,
  String[1] $command,
  Variant[String[1], Array[String[1]]] $on_calendar = [],
  Optional[String[1]] $on_boot_sec = undef,
  Optional[String[1]] $on_unit_active_sec = undef,
  Optional[String[1]] $randomized_delay_sec = undef,
  Boolean $persistent = true,
  String[1] $user = 'root',
  Variant[String[1], Boolean[false]] $group = 'systemd-journal',
  Array[String[1]] $after = [],
  Array[String[1]] $wants = [],
  Enum['present', 'absent'] $ensure = 'present',
) {
  if $title !~ /\A[a-zA-Z0-9:_.@-]+\z/ {
    fail("timer[${title}]: not a valid systemd unit name")
  }

  $calendars = [$on_calendar].flatten
  if $ensure == 'present' and $calendars.empty and !$on_boot_sec and !$on_unit_active_sec {
    fail("timer[${title}]: set at least one of on_calendar, on_boot_sec, on_unit_active_sec")
  }

  $service_file = "/etc/systemd/system/${title}.service"
  $timer_file = "/etc/systemd/system/${title}.timer"

  if $ensure == 'present' {
    file { $service_file:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('timer/service.epp', {
        description => $description,
        command     => $command,
        user        => $user,
        group       => $group,
        after       => $after,
        wants       => $wants,
      }),
    }

    file { $timer_file:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('timer/timer.epp', {
        description          => $description,
        on_calendar          => $calendars,
        on_boot_sec          => $on_boot_sec,
        on_unit_active_sec   => $on_unit_active_sec,
        randomized_delay_sec => $randomized_delay_sec,
        persistent           => $persistent,
        unit                 => "${title}.service",
      }),
      require => File[$service_file],
    }

    service { "${title}.timer":
      ensure    => running,
      enable    => true,
      subscribe => [File[$service_file], File[$timer_file]],
    }
  } else {
    service { "${title}.timer":
      ensure => stopped,
      enable => false,
    }

    file { [$timer_file, $service_file]:
      ensure  => absent,
      require => Service["${title}.timer"],
      notify  => Exec["timer-${title}-daemon-reload"],
    }

    exec { "timer-${title}-daemon-reload":
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
    }
  }
}
