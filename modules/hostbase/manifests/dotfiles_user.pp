define hostbase::dotfiles_user (
  $user = $name,
){
  if $user == 'root' {
    $base_dir = "/root"
  } else {
    $base_dir = "/home/${user}"
  }
  file { "${base_dir}/.vim":
    ensure   => absent,
    force    => true,
  }
  file { "${base_dir}/.vimrc":
    ensure  => absent,
  }
  file { "${base_dir}/.bash_completion":
    ensure  => absent,
  }
  file { "${base_dir}/.dotfiles":
    ensure  => absent,
    force    => true,
  }

  file { "${base_dir}/.config":
    ensure  => directory,
    owner   => "${user}",
    group   => "${user}",
  }

  vcsrepo { "${base_dir}/.config/dotfiles":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dotfiles.git',
    revision => 'master',
    require  => [File["${base_dir}/.config"], File["${base_dir}/.dotfiles"]],
    notify   => Exec["dotfiles-${user}-permissions"],
  }
  exec { "dotfiles-${user}-permissions":
    command     => "/bin/chown -R ${user}:${user} ${base_dir}/.config/dotfiles",
    refreshonly => true,
  }
  file { "${base_dir}/.bashrc":
    ensure  => link,
    target  => "${base_dir}/.config/dotfiles/.bashrc",
    owner   => "${user}",
    group   => "${user}",
    require => Vcsrepo["${base_dir}/.config/dotfiles"],
  }
  file { "${base_dir}/.bashrc.d":
    ensure  => link,
    target  => "${base_dir}/.config/dotfiles/.bashrc.d",
    owner   => "${user}",
    group   => "${user}",
    require => Vcsrepo["${base_dir}/.config/dotfiles"],
  }
  file { "${base_dir}/.bash_completion.d":
    ensure  => link,
    target  => "${base_dir}/.config/dotfiles/.bash_completion.d",
    owner   => "${user}",
    group   => "${user}",
    require => Vcsrepo["${base_dir}/.config/dotfiles"],
  }
  file { "${base_dir}/.ssh":
    ensure => directory,
    owner  => "${user}",
    group  => "${user}",
    mode   => '0700',
  }
  file { "${base_dir}/.ssh/environment":
    ensure  => file,
    owner   => "${user}",
    group   => "${user}",
    mode    => '0600',
    force   => true,
    require => File["${base_dir}/.ssh"],
  }
  file { "${base_dir}/.gitconfig":
    ensure  => link,
    target  => "${base_dir}/.config/dotfiles/.gitconfig",
    owner   => "${user}",
    group   => "${user}",
    require => Vcsrepo["${base_dir}/.config/dotfiles"],
  }

  vcsrepo { "${base_dir}/.config/nvim":
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/nvim-config.git',
    revision => 'main',
    require  => File["${base_dir}/.config"],
    notify   => Exec["nvim-${user}-permissions"],
  }
  exec { "nvim-${user}-permissions":
    command     => "/bin/chown -R ${user}:${user} ${base_dir}/.config/nvim",
    refreshonly => true,
  }
}