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

  # Sync when the server has a newer homelab database than the local one, e.g. on first
  # use or after a new package was published, so packages from the repo install right
  # away instead of failing until the next daily sync. pacman gives the local database
  # the server's mtime, so `curl -z` (If-Modified-Since) answers 200 only for a newer one;
  # an unreachable repo (000) doesn't trigger it. Sync with a full upgrade (the daily
  # pacman-update job), never a bare `pacman -Sy`, which would risk a partial upgrade.
  # The URL must match the Server line in files/pacman-homelab-repo.
  exec { 'sync homelab repo':
    command => '/usr/bin/systemctl start pacman-update.service',
    onlyif  => "/usr/bin/sh -c 'test \"$(/usr/bin/curl -s -o /dev/null -w %{http_code} --max-time 30 -z /var/lib/pacman/sync/homelab.db https://arch.srv.gentoomaniac.net/homelab.db)\" = 200'",
    timeout => 1800,
    require => [File_line['pacman.conf: include homelab repo'], Timer['pacman-update']],
  }

  # Once pacman.conf includes the repo, every `pacman -S` fails until its database
  # exists ("could not find database"), so install packages only after the sync.
  Exec['sync homelab repo'] -> Package <| |>
}
