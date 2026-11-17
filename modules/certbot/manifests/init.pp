class certbot (
  Array[String] $domains,
  Integer $interval = 80,
  String $certbot_image = 'certbot/dns-google',
  # a fixed tag: with 'latest', docker::image re-checks and pulls the image on every Puppet run,
  # which also counts as a change (exit 2). certbot publishes no floating version tags.
  String $image_tag = 'v5.10.0',
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
