define certbot::cert (
  String $email,
  String $image,
  String $domain = $title,
) {
  $normalized = regsubst(regsubst($domain, '\*\.', '', 'G'), '\.', '_', 'G')

  btrfs::subvolume { "/srv/certbot-${normalized}":
    ensure  => present,
  }

  file { "/srv/certbot-${normalized}/data":
    ensure  => directory,
    require => Btrfs::Subvolume["/srv/certbot-${normalized}"],
  }

  file  { "/srv/certbot-${normalized}/sa.json":
    ensure  => file,
    content => lookup('secret_cloud_dns'),
    mode    => "0600",
    require => Btrfs::Subvolume["/srv/certbot-${normalized}"],
  }

  timer { "certbot-${normalized}":
    description          => "Run certbot container for ${domain}",
    command              => "/usr/local/bin/renew-cert --domain='${domain}' --email='${email}' --image='${image}'",
    on_calendar          => 'daily',
    randomized_delay_sec => '1h',
    require              => [
      File["/srv/certbot-${normalized}/data"],
      File["/srv/certbot-${normalized}/sa.json"],
      File['/usr/local/bin/renew-cert'],
      Docker::Image[$certbot::certbot_image]],
  }
}
