# @summary Unattended reboot, docker prune and pacman cache cleanup, each run by a systemd timer
#
# @param reboot_on_calendar OnCalendar of the unattended reboot. The default is
#   outside the pacman-update window (04:00 plus up to 1h delay).
# @param reboot_randomized_delay RandomizedDelaySec of the unattended reboot.
class hostbase::maintenance (
  String[1] $reboot_on_calendar = '*-*-* 06:00:00',
  String[1] $reboot_randomized_delay = '1h',
) {
  file { '/usr/local/bin/unattended-reboot':
    ensure  => present,
    mode    => '0754',
    content => file('hostbase/unattended-reboot.sh'),
  }
  file { '/usr/local/bin/docker-system-prune':
    ensure  => present,
    mode    => '0750',
    content => file('hostbase/docker-system-prune.sh'),
  }
  file { '/usr/local/bin/paccache-cleanup':
    ensure  => present,
    mode    => '0750',
    content => file('hostbase/paccache-cleanup.sh'),
    require => Package['pacman-contrib'],
  }

  timer { 'unattended-reboot':
    description          => 'reboot after a kernel upgrade or 7 days of uptime, outside the pacman-update window',
    command              => '/usr/local/bin/unattended-reboot',
    on_calendar          => $reboot_on_calendar,
    randomized_delay_sec => $reboot_randomized_delay,
    require              => File['/usr/local/bin/unattended-reboot'],
  }
  timer { 'docker-system-prune':
    description => 'docker system prune after a random delay',
    command     => '/usr/local/bin/docker-system-prune',
    # Sunday 03:00 finishes before the daily unattended-reboot window starting 06:00
    on_calendar => 'Sun *-*-* 03:00:00',
    require     => File['/usr/local/bin/docker-system-prune'],
  }
  timer { 'paccache-cleanup':
    description => 'paccache cleanup after a random delay',
    command     => '/usr/local/bin/paccache-cleanup',
    # Sunday 03:00 finishes before the daily unattended-reboot window starting 06:00
    on_calendar => 'Sun *-*-* 03:00:00',
    require     => File['/usr/local/bin/paccache-cleanup'],
  }

  # TEMPORARY cleanup of the pre-`timer` units (`<name>-weekly.timer` became `<name>.timer`).
  # Remove this loop once all hosts have applied it.
  ['unattended-reboot', 'docker-system-prune', 'paccache-cleanup'].each |$unit| {
    service { "${unit}-weekly.timer":
      ensure => stopped,
      enable => false,
    }
    file { "/etc/systemd/system/${unit}-weekly.timer":
      ensure  => absent,
      require => Service["${unit}-weekly.timer"],
    }
  }
}
