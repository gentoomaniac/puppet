class certbot (
  String $domain,
  Integer $interval = 80,
  String $certbot_image = 'certbot/dns-google',
  String $image_tag = 'latest',
  String $email = 'marco@siebecke.se',
) {
  $normalized = regsubst(regsubst($domain, '\*\.', '', 'G'), '\.', '_', 'G')
  $simpledomain = regsubst($domain, '\*\.', '', 'G')

  zfs { "datapool/certbot-${normalized}":
    ensure  => present,
  }

  file { "/srv/certbot-${normalized}/data":
    ensure  => directory,
    require => Zfs["datapool/certbot-${normalized}"],
  }

  file  { "/srv/certbot-${normalized}/sa.json":
    ensure  => file,
    content => lookup('secret_cloud_dns'),
    mode    => "0600",
    require => Zfs["datapool/certbot-${normalized}"],
  }

  docker::image { $certbot_image:
    image_tag => $image_tag,
  }

  file { '/usr/local/bin/renew-cert':
    ensure => file,
    mode   => '0700',
    source => 'puppet:///modules/certbot/renew-cert.sh',
  }

  file { "systemd-service-${normalized}":
    ensure   => file,
    path     => "/etc/systemd/system/certbot-${normalized}.service",
    content  => epp('certbot/service.epp', {
      domain => $domain,
      email  => $email,
      image  => "${certbot_image}:${image_tag}",
    }),
    require  => [
      File["/srv/certbot-${normalized}/data"],
      File["/srv/certbot-${normalized}/sa.json"],
      File['/usr/local/bin/renew-cert'],
      Docker::Image[$certbot_image]],
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
