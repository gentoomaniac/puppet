class ldap_server(
  $ldap_organisation,
  $ldap_domain,
  $ssl_cert_location,
  $args = ['--copy-service'],
  $labels = [],
  $image = 'osixia/openldap',
  $tag = 'stable',
  $ports = ['389:389/tcp', '636:636/tcp'],
  $base_dir = '/srv/openldap',
  $bootstrap_dir = "${base_dir}/bootstrap",
  $schema_dir = "${base_dir}/schema",
  $data_dir = "${base_dir}/data",
  $env_file = "${base_dir}/env",
  $ssl_cert_name = 'fullchain1.pem',
  $ssl_key_name = 'privkey1.pem',
  $hostname     = 'ldap.srv.gentoomaniac.net',
){
  file { $base_dir:
    ensure  => directory,
    require => File['/srv'],
  }
  file { $bootstrap_dir:
    ensure  => directory,
    require => File[$base_dir],
  }
  file { $schema_dir:
    ensure  => directory,
    require => File[$base_dir],
  }
  file { $data_dir:
    ensure  => directory,
    require => File[$base_dir],
  }


  docker::run { 'openldap':
    image            => "${image}:${tag}",
    command          => join($args, ' '),
    ports            => $ports,
    env              => ["LDAP_TLS_CRT_FILENAME=${ssl_cert_location}/${ssl_cert_name}",
                        "LDAP_TLS_KEY_FILENAME=${ssl_cert_location}/${ssl_key_name}",
                        "LDAP_ORGANISATION=${ldap_organisation}",
                        "LDAP_DOMAIN=${ldap_domain}"],
    env_file         => [$env_file],
    labels           => $labels,
    hostname         => $hostname,
    net              => ['docker_default'],
    dns              => hiera('dns::servers'),
    pull_on_start    => true,
    extra_parameters => ['--restart=unless-stopped'],
    volumes          => ["${bootstrap_dir}:/container/service/slapd/assets/config/bootstrap/ldif/custom:ro",
                          "${schema_dir}:/etc/ldap/slapd.d",
                          "${data_dir}:/var/lib/ldap",
                          "${ssl_cert_location}:/ssl:ro"],

    require          => [Class['docker']],
  }
}
