class hostbase::dotfiles() {
  create_resources('hostbase::dotfiles_user', lookup('dotfiles', undef, undef, {}))
}
