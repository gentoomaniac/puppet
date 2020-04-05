class certbot (
  String $domain = $name,
  Integer $interval = 80,
  String $certbot_image = 'registry.srv.gentoomaniac.net/certbot-ovh',
  String $image_tag = 'latest',
  String $email = 'marco@siebecke.se',
) {
  file { "/srv/certbot-${domain}":
    ensure  => directory,
    require => File['/srv'],
  }

  file { "/srv/certbot-${domain}/data":
    ensure  => directory,
    require => File["/srv/certbot-${domain}"],
  }

  docker::image { $certbot_image:
    image_tag => $image_tag,
  }

  cron::job { "certbot-cron-${domain}":
    command     => "docker run -v '/srv/certbot-${domain}/ovh.ini:/ovh.ini:ro' -v '/srv/certbot-${domain}/data:/etc/letsencrypt' ${certbot_image} certonly --dns-ovh --dns-ovh-credentials /ovh.ini --email ${email} --agree-tos --no-eff-email -d '${domain}'",
    minute      => '0',
    hour        => '0',
    date        => '1',
    month       => '*/2',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin"'],
    description => "Update ${domain} certificate every ${interval} days",
    require     => [File["/srv/certbot-${domain}/data"],Docker::Image[$certbot_image]],
  }

}
