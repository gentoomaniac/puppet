class hostbase::puppet {

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
      ensure  => latest,
      require => Apt::Source['puppet6'],
    }
  }
  elsif $facts['os']['architecture'] == 'aarm64' {
    package{ 'ruby-full':
      ensure => latest,
    }

    package{ 'puppet':
      provider => 'puppet_gem',
      ensure   => 'latest',
      require  => Package['ruby-full'],
    }
  }
