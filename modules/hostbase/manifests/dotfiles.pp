# Class: hostbase::dotfiles
#
#
class hostbase::dotfiles
{
  vcsrepo { '/home/marco/.vim':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/vim-config.git',
    revision => 'master',
    require  => User['marco'],
    notify   => Exec['.vim-permissions'],
  }
  exec { '.vim-permissions':
    command     => '/bin/chown -R marco.marco /home/marco/.vim',
    refreshonly => true,
  }
  file { '/home/marco/.vimrc':
    ensure  => link,
    target  => '/home/marco/.vim/.vimrc',
    owner   => 'marco',
    group   => 'marco',
    require => Vcsrepo['/home/marco/.vim'],
  }

  vcsrepo { '/home/marco/.dotfiles':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dotfiles.git',
    revision => 'master',
    require  => User['marco'],
    notify   => Exec['.dotfiles-permissions'],
  }
  exec { '.dotfiles-permissions':
    command     => '/bin/chown -R marco.marco /home/marco/.dotfiles',
    refreshonly => true,
  }
  file { '/home/marco/.bashrc':
    ensure  => link,
    target  => '/home/marco/.dotfiles/.bashrc',
    owner   => 'marco',
    group   => 'marco',
    require => Vcsrepo['/home/marco/.dotfiles'],
  }
  file { '/home/marco/.bash_completion':
    ensure  => link,
    target  => '/home/marco/.dotfiles/.bash_completion',
    owner   => 'marco',
    group   => 'marco',
    require => Vcsrepo['/home/marco/.dotfiles'],
  }
  file { '/home/marco/.bash_completion.d':
    ensure  => link,
    target  => '/home/marco/.dotfiles/.bash_completion.d',
    owner   => 'marco',
    group   => 'marco',
    require => Vcsrepo['/home/marco/.dotfiles'],
  }
  file { '/home/marco/.ssh':
    ensure => directory,
    owner  => marco,
    group  => marco,
    mode   => '0700',
  }
  file { '/home/marco/.ssh/environment':
    ensure  => file,
    owner   => marco,
    group   => marco,
    mode    => '0600',
    require => File['/home/marco/.ssh'],
  }
}
