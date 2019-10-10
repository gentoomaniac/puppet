class hostbase::puppet (
  $version = latest,
  $aarch64_facter_version = '3.12.2.cfacter.20181217',
  $aarch64_puppet_version = '6.9.0',
) {

  if $facts['os']['architecture'] == 'amd64' {
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
