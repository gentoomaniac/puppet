class hostbase::autoupdate {

  file { '/etc/systemd/system/pacman-update.service':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/hostbase/pacman-update.service',
    notify => Exec['pacman_update_daemon_reload'],
  }

  file { '/etc/systemd/system/pacman-update.timer':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/hostbase/pacman-update.timer',
    notify => Exec['pacman_update_daemon_reload'],
  }

  if !defined(Exec['pacman_update_daemon_reload']) {
    exec { 'pacman_update_daemon_reload':
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
    }
  }

  service { 'pacman-update.timer':
    ensure    => running,
    enable    => true,
    require   => [
      File['/etc/systemd/system/pacman-update.service'],
      File['/etc/systemd/system/pacman-update.timer']
    ],
    subscribe => Exec['pacman_update_daemon_reload'],
  }
}
