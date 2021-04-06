class certbot (
  String $domain,
  Integer $interval = 80,
  String $certbot_image = 'registry.srv.gentoomaniac.net/certbot-ovh',
  String $image_tag = 'latest',
  String $email = 'marco@siebecke.se',
) {
  $normalized = regsubst(regsubst($domain, '\*\.', '', 'G'), '\.', '_', 'G')
  $simpledomain = regsubst($domain, '\*\.', '', 'G')

  zfs { "/srv/certbot-${normalized}":
    ensure  => present,
  }

  file { "/srv/certbot-${normalized}/data":
    ensure  => directory,
    require => Zfs["/srv/certbot-${normalized}"],
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
    require => Zfs["/srv/certbot-${normalized}"],
  }

  docker::image { $certbot_image:
    image_tag => $image_tag,
  }

  file { '/usr/local/bin/renew-cert':
    ensure => file,
    mode   => '0700',
    source => 'puppet:///modules/certbot/renew-cert.sh',
  }

  cron::job { "certbot-cron-${normalized}":
    command     => "/usr/local/bin/renew-cert --domain='${domain}' --email='${email}' --image='${certbot_image}:${image_tag}'",
    minute      => '0',
    hour        => '3',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    environment => ['MAILTO=root', 'PATH="/usr/bin:/bin"'],
    description => "Update ${domain} certificate if necessary",
    require     => [
      File["/srv/certbot-${normalized}/data"],
      File["/srv/certbot-${normalized}/ovh.ini"],
      File['/usr/local/bin/renew-cert'],
      Docker::Image[$certbot_image]],
  }
}
