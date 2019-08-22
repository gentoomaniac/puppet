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
  }
  file { '/home/marco/.vim':
    ensure  => directory,
    owner   => 'marco',
    group   => 'marco',
    recurse => true,
    require => Vcsrepo['/home/marco/.vim'],
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
  }
  file { '/home/marco/.dotfiles':
    ensure  => directory,
    owner   => 'marco',
    group   => 'marco',
    recurse => true,
    require => Vcsrepo['/home/marco/.dotfiles'],
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
    target  => '/home/marco/.dotfiles/.bashcompletion.d',
    owner   => 'marco',
    group   => 'marco',
    require => Vcsrepo['/home/marco/.dotfiles'],
  }
}
