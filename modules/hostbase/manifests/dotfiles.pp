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
  file { '/home/marco/.vimrc':
    ensure  => link,
    target  => '/home/marco/.vim/.vimrc',
    require => Vcsrepo['/home/marco/.vim'],
  }

  vcsrepo { '/home/marco/.dotfiles':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/gentoomaniac/dotfiles.git',
    revision => 'master',
  }
  file { '/home/marco/.bashrc':
    ensure  => link,
    target  => '/home/marco/.dotfiles/.bashrc',
    require => Vcsrepo['/home/marco/.dotfiles'],
  }
  file { '/home/marco/.bash_completion':
    ensure  => link,
    target  => '/home/marco/.dotfiles/.bash_completion',
    require => Vcsrepo['/home/marco/.dotfiles'],
  }
  file { '/home/marco/.bash_completion.d':
    ensure  => link,
    target  => '/home/marco/.dotfiles/.bashcompletion.d',
    require => Vcsrepo['/home/marco/.dotfiles'],
  }
}
