#!/usr/bin/env python3
"""Import a GitHub user's own repos into Forgejo.

Imports into the Forgejo account the Forgejo token belongs to, with issues, labels,
milestones, pull requests, releases, wiki and LFS, keeping each repo's visibility; archived
repos are archived in Forgejo too. Repos that already exist in Forgejo are skipped, so a
partial run can simply be repeated.

Which repos: the ones named as arguments or in --repo-list (forks included), or, when none
are named, every repo the GitHub token's user owns except forks (archived ones included).

Tokens come from the environment or from an env file (KEY=value lines):

\b
- GITHUB_TOKEN: fine-grained, all repositories; Contents, Issues, Pull requests and
  Metadata read-only.
- FORGEJO_TOKEN: repository read and write, user read.
"""

import json
import os
import sys
import urllib.error
import urllib.request

import click

GITHUB_API = 'https://api.github.com'
GITHUB_PAGE_SIZE = 100  # GitHub's maximum per_page
# the API only answers once a repo is imported, which takes a while for big ones
IMPORT_TIMEOUT_S = 3600
REQUEST_TIMEOUT_S = 60


def read_env_file(path):
    """KEY=value lines of an env file; missing file gives {}."""
    values = {}
    if os.path.exists(path):
        with open(path) as env:
            for line in env:
                key, sep, value = line.strip().partition('=')
                if sep and not key.startswith('#'):
                    values[key.strip()] = value.strip().strip('"\'')
    return values


def call(url, auth, method='GET', body=None, timeout=REQUEST_TIMEOUT_S):
    """HTTP JSON call; returns (status, parsed JSON or None). Network errors give status None."""
    data = json.dumps(body).encode() if body is not None else None
    request = urllib.request.Request(url, data=data, method=method)
    request.add_header('Authorization', auth)
    request.add_header('Accept', 'application/json')
    if data is not None:
        request.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            raw = response.read()
            return response.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as error:
        raw = error.read()
        try:
            return error.code, json.loads(raw)
        except ValueError:
            return error.code, {'message': raw.decode(errors='replace')}
    except (urllib.error.URLError, TimeoutError) as error:
        return None, {'message': str(getattr(error, 'reason', error))}


def message(result):
    return result.get('message', result) if isinstance(result, dict) else result


def github_repos(token):
    """The token user's own repos (owner affiliation: no org or collaborator repos), sorted by name."""
    repos, page = [], 1
    while True:
        status, batch = call(f'{GITHUB_API}/user/repos?affiliation=owner&per_page={GITHUB_PAGE_SIZE}&page={page}',
                             f'Bearer {token}')
        if status != 200:
            sys.exit(f'listing GitHub repos failed: HTTP {status} {message(batch)}')
        repos += batch
        if len(batch) < GITHUB_PAGE_SIZE:
            return sorted(repos, key=lambda r: r['name'].lower())
        page += 1


def read_repo_list(file):
    """Repo names from a plain list: one per line, blank lines and # comments ignored."""
    names = []
    for line in file:
        name = line.partition('#')[0].strip()
        if name:
            names.append(name)
    return names


@click.command(help=__doc__)
@click.argument('names', nargs=-1, metavar='[REPO]...')
@click.option('--repo-list', type=click.File(), metavar='FILE', help='File with repo names, one per line (- for stdin).')
@click.option('--apply', is_flag=True, help='Import. Without it, only print the plan.')
@click.option('--forgejo-url', default='https://forgejo.srv.gentoomaniac.net', show_default=True)
@click.option('--env-file', default='~/.config/forgejo-migrate.env', show_default=True,
              help='Where to read GITHUB_TOKEN and FORGEJO_TOKEN when they aren\'t in the environment.')
def main(names, repo_list, apply, forgejo_url, env_file):
    env = read_env_file(os.path.expanduser(env_file))
    github_token = os.environ.get('GITHUB_TOKEN') or env.get('GITHUB_TOKEN')
    forgejo_token = os.environ.get('FORGEJO_TOKEN') or env.get('FORGEJO_TOKEN')
    if not github_token or not forgejo_token:
        sys.exit(f'GITHUB_TOKEN and FORGEJO_TOKEN must be set (environment or {env_file})')

    def forgejo(method, path, body=None, timeout=REQUEST_TIMEOUT_S):
        return call(f'{forgejo_url}/api/v1{path}', f'token {forgejo_token}', method, body, timeout)

    listed = read_repo_list(repo_list) if repo_list else []
    if repo_list and not listed:
        sys.exit(f'{repo_list.name} lists no repos')
    wanted = set(names) | set(listed)
    repos = github_repos(github_token)
    if wanted:
        unknown = wanted - {r['name'] for r in repos}
        if unknown:
            sys.exit(f'not among your GitHub repos: {", ".join(sorted(unknown))}')
        repos = [r for r in repos if r['name'] in wanted]
    else:
        repos = [r for r in repos if not r['fork']]

    status, me = forgejo('GET', '/user')
    if status != 200:
        sys.exit(f'Forgejo token check failed: HTTP {status} {message(me)}')
    owner = me['login']

    failed = 0
    for repo in repos:
        name = repo['name']
        kind = ', '.join(k for k, on in (('fork', repo['fork']), ('private', repo['private']),
                                         ('archived', repo['archived'])) if on)
        label = f"{owner}/{name}{f' ({kind})' if kind else ''}"

        status, result = forgejo('GET', f'/repos/{owner}/{name}')
        if status == 200:
            click.echo(f'EXISTS  {label}')
            continue
        if status != 404:
            click.echo(f'SKIP    {label}: checking for it failed: HTTP {status} {message(result)}')
            failed += 1
            continue
        if not apply:
            click.echo(f'PLAN    {label}: import from {repo["html_url"]}')
            continue

        click.echo(f'IMPORT  {label} ...')
        status, result = forgejo('POST', '/repos/migrate', {
            'clone_addr': repo['clone_url'],
            'service': 'github',
            'auth_token': github_token,
            'repo_owner': owner,
            'repo_name': name,
            'description': repo.get('description') or '',
            'private': repo['private'],
            'mirror': False,
            'wiki': repo.get('has_wiki', False),
            'issues': True,
            'labels': True,
            'milestones': True,
            'pull_requests': True,
            'releases': True,
            'lfs': True,
        }, timeout=IMPORT_TIMEOUT_S)
        if status != 201:
            click.echo(f'  failed: HTTP {status} {message(result)}')
            failed += 1
            continue
        if repo['archived']:
            status, result = forgejo('PATCH', f'/repos/{owner}/{name}', {'archived': True})
            if status != 200:
                click.echo(f'  archiving failed: HTTP {status} {message(result)}')
                failed += 1

    click.echo(f"\n{len(repos)} repos, {failed} failed{'' if apply else '; nothing changed, run with --apply to import'}")
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
