class certbot (
  Array[String] $domains,
  Integer $interval = 80,
  String $certbot_image = 'certbot/dns-google',
  String $image_tag = 'latest',
  String $email = 'marco@siebecke.se',
) {
  docker::image { $certbot_image:
    image_tag => $image_tag,
  }

  file { '/usr/local/bin/renew-cert':
    ensure => file,
    mode   => '0700',
    source => 'puppet:///modules/certbot/renew-cert.sh',
  }

  certbot::cert { $domains:
    email => $email,
    image => "${certbot_image}:${image_tag}",
  }
}
