class hostbase {
  include hostbase::syslog
  apt::key {'gcloud-gpg-key':
    source  => 'https://packages.cloud.google.com/apt/doc/apt-key.gpg',
    id      => '54A647F9048D5688D7DA2ABE6A030B21BA07F4FB',
    server  => 'pgp.mit.edu',
  }

  apt::source { 'gcloud-repo':
    location     => 'http://packages.cloud.google.com/apt',
    release      => "cloud-sdk-${facts['os']['distro']['codename']}",
    repos        => 'main',
    require      => Apt::Key['gcloud-gpg-key'],
  }

  package { 'google-cloud-sdk':
    ensure  => latest,
    require => Apt::Source['gcloud-repo'],
  }

}
