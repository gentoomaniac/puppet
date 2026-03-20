define btrfs::subvolume (
  String $path = $title,
  String $ensure = 'present',
) {
  if $ensure == 'present' {
    exec { "create_btrfs_subvol_${name}":
      command => "/usr/bin/btrfs subvolume create ${path}",
      creates => $path,
    }

    exec { "disable_cow_${name}":
      command     => "/usr/bin/chattr +C ${path}",
      refreshonly => true,
      subscribe   => Exec["create_btrfs_subvol_${name}"],
    }
  } elsif $ensure == 'absent' {
    exec { "delete_btrfs_subvol_${name}":
      command => "/usr/bin/btrfs subvolume delete ${path}",
      onlyif  => "/usr/bin/test -d ${path}",
    }
  }
}
