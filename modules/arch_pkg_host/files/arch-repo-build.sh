#!/usr/bin/env bash
# Builds the homelab pacman repo from PKGBUILDs in GitHub repos.
#
# Runs as root inside a throwaway archlinux container (see the arch_pkg_host class),
# with the repo directory mounted at /repo and the config at /etc/arch-repo-build.conf.
#
# The config lists one GitHub repo URL per line (https://github.com/<owner>/<repo>);
# blank lines and # comments are ignored. For each repo the PKGBUILD from the default
# branch is fetched. If its package files are already in the repo, the repo is skipped;
# otherwise the package is built and added to the repo database. The repo is only
# cloned (shallow) when the PKGBUILD refers to local source files.
#
# makepkg refuses to run as root, so everything that touches the PKGBUILD runs as an
# unprivileged build user; copying into the repo and repo-add run as root, so the repo
# files stay root-owned on the host. Packages are unsigned.
set -uo pipefail

CONFIG=/etc/arch-repo-build.conf
REPO_DIR=/repo
REPO_DB="${REPO_DIR}/homelab.db.tar.gz"
BUILD_USER=builder

as_builder() {
  runuser -u "${BUILD_USER}" -- "$@"
}

# prints the values of a .SRCINFO key, e.g. `srcinfo_values source "${srcinfo}"`;
# also matches the per-architecture variants like source_x86_64
srcinfo_values() {
  sed -n -E "s/^[[:space:]]*$1(_[a-z0-9_]+)? = //p" <<<"$2"
}

# true if the PKGBUILD needs files from the repo checkout: a source entry without a
# URL, or an install/changelog file
has_local_sources() {
  local entry
  [ -n "$(srcinfo_values install "$1")$(srcinfo_values changelog "$1")" ] && return 0
  while read -r entry; do
    [ -z "${entry}" ] && continue
    entry="${entry#*::}"
    [[ "${entry}" == *://* ]] || return 0
  done < <(srcinfo_values source "$1")
  return 1
}

build_repo() {
  local url="$1" slug name builddir srcinfo pkglist pkg
  local -a packages=() missing=() added=()

  if [[ ! "${url}" =~ ^https?://github\.com/([^/[:space:]]+/[^/[:space:]]+)$ ]]; then
    echo "${url}: not a GitHub repo URL (https://github.com/<owner>/<repo>)" >&2
    return 1
  fi
  slug="${BASH_REMATCH[1]%.git}"
  name="${slug##*/}"
  builddir="${workdir}/${name}"
  as_builder mkdir -p "${builddir}"

  if ! as_builder curl -fsSL -o "${builddir}/PKGBUILD" "https://raw.githubusercontent.com/${slug}/HEAD/PKGBUILD"; then
    echo "${slug}: fetching the PKGBUILD failed" >&2
    return 1
  fi
  if ! srcinfo="$(cd "${builddir}" && as_builder makepkg --printsrcinfo)"; then
    echo "${slug}: reading the PKGBUILD failed" >&2
    return 1
  fi

  if has_local_sources "${srcinfo}"; then
    builddir="${workdir}/${name}.git"
    if ! as_builder git clone --quiet --depth 1 "https://github.com/${slug}.git" "${builddir}"; then
      echo "${slug}: cloning failed" >&2
      return 1
    fi
  fi

  # the package files this PKGBUILD version produces
  if ! pkglist="$(cd "${builddir}" && as_builder makepkg --packagelist)" || [ -z "${pkglist}" ]; then
    echo "${slug}: listing the package files failed" >&2
    return 1
  fi
  mapfile -t packages <<<"${pkglist}"
  for pkg in "${packages[@]}"; do
    [ -e "${REPO_DIR}/${pkg##*/}" ] || missing+=("${pkg##*/}")
  done
  if [ "${#missing[@]}" -eq 0 ]; then
    echo "${slug}: up to date"
    return 0
  fi

  echo "${slug}: building ${missing[*]}"
  # --nodeps: runtime dependencies don't have to be installed in the build container;
  # missing makedepends still fail the build
  if ! (cd "${builddir}" && as_builder makepkg --noconfirm --nodeps --cleanbuild --clean); then
    echo "${slug}: build failed" >&2
    return 1
  fi

  # A package file in the repo directory counts as built, so on any failure remove what
  # this run copied; otherwise the next run would skip a package that isn't in the database.
  # Copy under a temporary name first, so nginx never serves a half-written file.
  for pkg in "${packages[@]}"; do
    [ -e "${REPO_DIR}/${pkg##*/}" ] && continue
    added+=("${REPO_DIR}/${pkg##*/}")
    if ! install -m 0644 "${pkg}" "${REPO_DIR}/.${pkg##*/}.part" \
        || ! mv "${REPO_DIR}/.${pkg##*/}.part" "${REPO_DIR}/${pkg##*/}"; then
      echo "${slug}: copying ${pkg##*/} into the repo failed" >&2
      rm -f "${REPO_DIR}/.${pkg##*/}.part" "${added[@]}"
      return 1
    fi
  done
  # --remove deletes the package files of the versions these replace
  if ! repo-add --remove "${REPO_DB}" "${added[@]}"; then
    echo "${slug}: repo-add failed" >&2
    rm -f "${added[@]}"
    return 1
  fi
}

if [ ! -r "${CONFIG}" ]; then
  echo "${CONFIG} not readable" >&2
  exit 1
fi

# leftovers of a run that was killed while copying
rm -f "${REPO_DIR}"/.*.part

echo "preparing the build container ..."
if ! pacman -Syu --noconfirm --needed --noprogressbar base-devel git >/dev/null; then
  echo "installing base-devel and git failed" >&2
  exit 1
fi
useradd --create-home "${BUILD_USER}" || exit 1
workdir="$(as_builder mktemp -d)" || exit 1

# The config is read on fd 3, so build steps that read stdin can't eat its lines.
# Runs can't overlap: the timer names the container, and docker refuses a second one.
failed=0
while read -r line <&3; do
  line="${line%%#*}"
  line="${line//[[:space:]]/}"
  [ -z "${line}" ] && continue
  build_repo "${line%/}" </dev/null || failed=1
done 3< "${CONFIG}"

exit "${failed}"
