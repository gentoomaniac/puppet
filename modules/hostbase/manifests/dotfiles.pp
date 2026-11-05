class hostbase::dotfiles() {
  $dotfiles = lookup('dotfiles', undef, undef, {})

  unless $dotfiles.empty {
    # the dotfiles' shell prompt (powerline-go), from the homelab pacman repo
    package { 'powerline-go-bin':
      ensure => installed,
    }
  }

  create_resources('hostbase::dotfiles_user', $dotfiles)
}
