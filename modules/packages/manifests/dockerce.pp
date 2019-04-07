class packages::dockerce {
  $old_packages = ['docker', 'docker-engine', 'docker.io', 'containerd', 'runc']
  package { $old_packages :
    ensure => absent,
  }

  $dependencies = ['apt-transport-https', 'ca-certificates', 'curl', 'gnupg-agent', 'software-properties-common']
  package { $dependencies :
    ensure => latest,
  }

  apt::key {'docker-gpg-key':
    source  => 'https://download.docker.com/linux/ubuntu/gpg',
    id      => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
    server  => 'pgp.mit.edu',
    require => Package[$dependencies],
  }

  apt::source { 'docker-ce':
    location     => 'https://download.docker.com/linux/ubuntu',
    release      => $facts['os']['distro']['codename'],
    repos        => 'stable',
    architecture => 'amd64',
    require      => Apt::Key['docker-gpg-key'],
  }

  $new_packages = ['docker-ce', 'docker-ce-cli', 'containerd.io']
  package { $new_packages :
    ensure  => latest,
    require => [ Apt::Source['docker-ce'], Package[$old_packages] ],
  }
}
