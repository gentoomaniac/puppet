class hostbase::autoupdate {

  timer { 'pacman-update':
    description          => 'Arch Linux Automatic Updates',
    # Update keyring first to prevent PGP signature errors, then update system
    command              => "/usr/bin/sh -c '/usr/bin/pacman -Sy archlinux-keyring --noconfirm && /usr/bin/pacman -Su --noconfirm'",
    # Run daily at 4:00 AM
    on_calendar          => '*-*-* 04:00:00',
    # Spread the load across the fleet by randomizing start time by up to 1 hour
    randomized_delay_sec => '60m',
    group                => false,
    after                => ['network-online.target'],
    wants                => ['network-online.target'],
  }
}
