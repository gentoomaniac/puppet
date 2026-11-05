# @summary The homelab pacman repo (self-built tooling like run-puppet), served by arch_pkg_host
#
# The repo is a single point of failure: while it's unreachable, `pacman -Sy` fails
# and the daily pacman-update skips the upgrade. The repo is only synced by that daily
# upgrade, so a newly published package only becomes installable after the next daily
# sync; until then the puppet run fails for that package.
# bootstrap.sh sets up the same repo file and Include line, and syncs it, before the
# first puppet run.
class hostbase::pacman {
  file { '/etc/pacman.d/homelab-repo':
    ensure  => file,
    content => file('hostbase/pacman-homelab-repo'),
  }

  # The repo file starts with its own [homelab] section, so appending the Include works.
  file_line { 'pacman.conf: include homelab repo':
    path    => '/etc/pacman.conf',
    line    => 'Include = /etc/pacman.d/homelab-repo',
    require => File['/etc/pacman.d/homelab-repo'],
  }
}
