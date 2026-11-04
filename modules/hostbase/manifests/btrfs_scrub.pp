# @summary periodic btrfs scrub from btrfsmaintenance
class hostbase::btrfs_scrub {
  service { 'btrfs-scrub.timer':
    ensure  => running,
    enable  => true,
    require => Package['btrfsmaintenance'],
  }
}
