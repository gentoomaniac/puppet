class hostbase::puppet (
  $version = latest,
  $aarch64_facter_version = '3.12.2.cfacter.20181217',
  $aarch64_puppet_version = '6.9.0',
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

    package { 'puppet':
      ensure => absent,
    }

    package { 'puppet-agent':
      ensure  => "${version}-1bionic",
      require => [Apt::Source['puppet6'],Package['puppet']],
    }

    service { 'puppet':
      ensure  => 'stopped',
      enable  => false,
      require => Package['puppet-agent'],
    }
  }
  elsif $facts['os']['architecture'] == 'aarch64' {
    $dependencies = ['ruby-full', 'build-essentials', 'libboost-all-dev', 'libyaml-cpp-dev']
    package{ $dependencies :
      ensure => latest,
    }

    package{ 'facter':
      ensure   => $aarch64_facter_version,
      provider => 'gem',
      require  => Package[$dependencies],
    }
    package{ 'puppet':
      ensure   => $aarch64_puppet_version,
      provider => 'gem',
      require  => [Package[$dependencies], Package['facter']],
    }
  }
}
