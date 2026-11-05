# @summary The homelab pacman repo (self-built tooling like run-puppet), served by arch_pkg_host
#
# The repo is a single point of failure: while it's unreachable, `pacman -Sy` fails
# and the daily pacman-update skips the upgrade. bootstrap.sh sets up the same repo
# file and Include line for the first puppet run.
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

  # A newly added repo has no package list until the next sync. Sync with a full
  # upgrade (the daily pacman-update job), never a bare `pacman -Sy`, which would
  # risk a partial upgrade. Once the homelab database is synced, `pacman -Si` reads
  # it locally, so this only runs once per host.
  exec { 'sync homelab repo':
    command => '/usr/bin/systemctl start pacman-update.service',
    unless  => '/usr/bin/pacman -Si homelab/run-puppet',
    timeout => 1800,
    require => [File_line['pacman.conf: include homelab repo'], Timer['pacman-update']],
  }
}
