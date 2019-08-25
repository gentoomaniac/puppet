class hostbase::puppet (
  $version = latest,
) {

  if $facts['os']['architecture'] == 'amd64' {
    apt::key {'puppet6-gpg-key':
      id     => '7F438280EF8D349F',
      server => 'keyserver.ubuntu.com',
    }

    apt::source { 'puppet6':
      location => 'http://apt.puppetlabs.com',
      release  => $facts['os']['distro']['codename'],
      repos    => 'puppet6',
      require  => Apt::Key['puppet6-gpg-key'],
    }

    package { 'puppet-agent':
      ensure  => $version,
      require => Apt::Source['puppet6'],
    }

    service { 'puppet':
      ensure  => 'stopped',
      enable  => false,
      require => Package['puppet-agent'],
    }
  }
  elsif $facts['os']['architecture'] == 'aarch64' {
    package{ 'ruby-full':
      ensure => latest,
    }

    package{ 'puppet':
      ensure   => $version,
      provider => 'gem',
      require  => Package['ruby-full'],
    }
  }
}
