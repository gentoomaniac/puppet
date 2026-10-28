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

  file { "systemd-service-${normalized}":
    ensure   => file,
    path     => "/etc/systemd/system/certbot-${normalized}.service",
    content  => epp('certbot/service.epp', {
      domain => $domain,
      email  => $email,
      image  => $image,
    }),
    require  => [
      File["/srv/certbot-${normalized}/data"],
      File["/srv/certbot-${normalized}/sa.json"],
      File['/usr/local/bin/renew-cert'],
      Docker::Image[$certbot::certbot_image]],
  }

  file { "systemd-timer-${normalized}":
    ensure   => file,
    path     => "/etc/systemd/system/certbot-${normalized}.timer",
    content  => epp('certbot/timer.epp', {
      domain => $domain,
      service => "certbot-${normalized}.service",
    }),
    require  => File["systemd-service-${normalized}"],
  }

  service { "certbot-${normalized}.timer":
    ensure  => running,
    enable  => true,
    require => File["systemd-timer-${normalized}"],
  }
}
