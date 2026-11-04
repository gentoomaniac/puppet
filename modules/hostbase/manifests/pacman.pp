# @summary pacman repository file for the homelab package host
class hostbase::pacman {
  file { '/etc/pacman.d/homelab-repo':
    ensure  => file,
    content => file('hostbase/pacman-homelab-repo'),
  }
}
