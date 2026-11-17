# Puppet

Masterless `puppet apply` setup for the Arch Linux hosts.

## Checks

CI (`.github/workflows/ci.yml`) runs the same tasks you can run locally:

```sh
bundle install
bundle exec rake lint   # puppet parser/epp/erb/ruby/python syntax, puppet-lint, yamllint, shellcheck
bundle exec rake spec   # compile the catalog of every host in hiera/mac/
```

`lint` needs `shellcheck` and `yamllint` on the PATH. Single checks are available as
`rake lint:puppet_parser`, `lint:epp`, `lint:erb`, `lint:puppet_lint`, `lint:ruby`, `lint:yaml`,
`lint:shell` and `lint:python`.

`spec` installs `puppetlabs-host_core` into `spec/fixtures/modules` (needs network) and compiles
`manifests/site.pp` with the real hiera hierarchy, minus the Vault level, which is replaced by
dummy values for every `secret_*` key. Facts are faked from the MAC file of each host.

## Scripts

Helper scripts for the homelab that don't run on the hosts live in `scripts/`, one folder each.
Python ones are packages with a `pyproject.toml` and are installed into a venv, e.g.:

```sh
python3 -m venv .venv
.venv/bin/pip install -e scripts/github-to-forgejo
.venv/bin/github-to-forgejo --help
```

- `github-to-forgejo/`: imports GitHub repos into Forgejo with issues, pull requests, releases and
  wiki, keeping visibility; see its README.
