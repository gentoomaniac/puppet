# Puppet

Masterless `puppet apply` setup for the Arch Linux hosts.

## Checks

CI (`.github/workflows/ci.yml`) runs the same tasks you can run locally:

```sh
bundle install
bundle exec rake lint   # puppet parser/epp/erb/ruby syntax, puppet-lint, yamllint, shellcheck
bundle exec rake spec   # compile the catalog of every host in hiera/mac/
```

`lint` needs `shellcheck` and `yamllint` on the PATH. Single checks are available as
`rake lint:puppet_parser`, `lint:epp`, `lint:erb`, `lint:puppet_lint`, `lint:ruby`, `lint:yaml`
and `lint:shell`.

`spec` installs `puppetlabs-host_core` into `spec/fixtures/modules` (needs network) and compiles
`manifests/site.pp` with the real hiera hierarchy, minus the Vault level, which is replaced by
dummy values for every `secret_*` key. Facts are faked from the MAC file of each host.
