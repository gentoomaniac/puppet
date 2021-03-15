class certbot (
  String $domain,
  Integer $interval = 80,
  String $certbot_image = 'registry.srv.gentoomaniac.net/certbot-ovh',
  String $image_tag = 'latest',
  String $email = 'marco@siebecke.se',
) {
  $normalized = regsubst(regsubst($domain, '\*\.', '', 'G'), '\.', '_', 'G')
  $simpledomain = regsubst($domain, '\*\.', '', 'G')

  file { "/srv/certbot-${normalized}":
    ensure  => directory,
    require => File['/srv'],
  }

  file { "/srv/certbot-${normalized}/data":
    ensure  => directory,
    require => File["/srv/certbot-${normalized}"],
  }

  $application_key = lookup('secret_ovh_application_key')
  $application_secret = lookup('secret_ovh_application_secret')
  $consumer_key = lookup('secret_ovh_consumer_key')
  $conf = "## MANAGED BY PUPPET ##
# OVH API credentials used by Certbot
dns_ovh_endpoint = ovh-eu
dns_ovh_application_key = ${application_key}
dns_ovh_application_secret = ${application_secret}
dns_ovh_consumer_key = ${consumer_key}
"
  file  { "/srv/certbot-${normalized}/ovh.ini":
    ensure  => file,
    content => $conf,
    mode    => "0600",
    require => File["/srv/certbot-${normalized}"],
  }

  docker::image { $certbot_image:
    image_tag => $image_tag,
  }

  $certbot_parameters = "certonly --dns-ovh --dns-ovh-credentials /ovh.ini --email ${email} --agree-tos --no-eff-email -d '${domain}'"
  cron::job { "certbot-cron-${normalized}":
    command     => "docker run -v '/srv/certbot-${normalized}/ovh.ini:/ovh.ini:ro' -v '/srv/certbot-${normalized}/data:/etc/letsencrypt' ${certbot_image} ${certbot_parameters}",
    minute      => '0',
    hour        => '0',
    date        => '1',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin"'],
    description => "Update ${domain} certificate every ${interval} days",
    require     => [File["/srv/certbot-${normalized}/data"],Docker::Image[$certbot_image]],
  }

  cron::job { "certbot-cron-${normalized}-update-chain":
    command     => "/usr/local/bin/mvault kv put puppet/common/secret_${normalized}_cert value=\"$(cat /srv/certbot-${normalized}/data/live/${simpledomain}/fullchain.pem)\"",
    minute      => '0',
    hour        => '2',
    date        => '1',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin"'],
    description => "Update ${domain} certificate chain in vault",
  }
  cron::job { "certbot-cron-${normalized}-update-privkey":
    command     => "/usr/local/bin/mvault kv put puppet/common/secret_${normalized}_key value=\"$(cat /srv/certbot-${normalized}/data/live/${simpledomain}/privkey.pem)\"",
    minute      => '0',
    hour        => '2',
    date        => '1',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin"'],
    description => "Update ${domain} certificate private key in vault",
  }

}
