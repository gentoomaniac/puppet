class certbot (
  String $domain = $name,
  Integer $interval = 80,
  String $certbot_image = 'registry.srv.gentoomaniac.net/certbot-ovh',
  String $image_tag = 'latest',
  String $email = 'marco@siebecke.se',
) {
  file { "/srv/certbot-${name}":
    ensure  => directory,
    require => File['/srv'],
  }

  docker::image { $certbot_image:
    image_tag => $image_tag,
  }

  cron::job { "certbot-cron-${name}":
    command     => "docker run -v '/srv/certbot-${name}/ovh.ini:/ovh.ini:ro' ${certbot_image} certbot certonly --dns-ovh --dns-ovh-credentials /ovh.ini --email ${email} --agree-tos --no-eff-email -d '${domain}'",
    minute      => '0',
    hour        => '0',
    date        => "*/${interval}",
    month       => '*',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin"'],
    description => "Update ${name} certificate every",
    require     => [File["/srv/certbot-${name}"],Docker::Image[$certbot_image]],
  }

}
