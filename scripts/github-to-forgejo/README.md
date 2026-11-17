# github-to-forgejo

Imports GitHub repos into Forgejo with issues, pull requests, releases and wiki, keeping their
visibility: the repos named as arguments or in `--repo-list FILE` (forks too), or else all your
own repos except forks. Archived repos are archived in Forgejo too. Prints the plan unless run with
`--apply`; repos already in Forgejo are skipped, so it can be rerun.

```sh
python3 -m venv .venv
.venv/bin/pip install -e scripts/github-to-forgejo
.venv/bin/github-to-forgejo --help
```

Tokens and their permissions: see `--help`.
