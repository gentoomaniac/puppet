class hostbase::puppet (
  $version = latest,
) {

  if $facts['os']['architecture'] == 'amd64' {
    apt::key {'puppet6-gpg-key':
      id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      server => 'keyserver.ubuntu.com',
    }

    apt::source { 'puppet6':
      location => 'http://apt.puppetlabs.com',
      release  => $facts['os']['distro']['codename'],
      repos    => 'puppet6',
      require  => Apt::Key['puppet6-gpg-key'],
    }

    package { 'puppet-agent':
      ensure  => "${version}-1bionic",
      require => Apt::Source['puppet6'],
    }

    service { 'puppet':
      ensure  => 'stopped',
      enable  => false,
      require => Package['puppet-agent'],
    }
  }
  elsif $facts['os']['architecture'] == 'aarch64' {
    $aarch64_packages = ['ruby-full', 'facter']
    package{ $aarch64_packages :
      ensure => latest,
    }

    file { '/usr/local/bin/facter':
      ensure => 'link',
      target => '/usr/bin/facter',
    }

    package{ 'puppet':
      ensure   => $version,
      provider => 'gem',
      require  => [Package[$aarch64_packages], File['/usr/local/bin/facter']],
    }
  }
}
