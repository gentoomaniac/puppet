#!/usr/bin/env bash
# Builds the homelab pacman repo from PKGBUILDs in GitHub repos.
#
# The config lists one GitHub repo URL per line (https://github.com/<owner>/<repo>);
# blank lines and # comments are ignored. Each repo needs a PKGBUILD at the root of
# its default branch. Packages are unsigned.
#
# Two modes:
# - On the host (the daily timer, as root): fetch every PKGBUILD and check whether its
#   package files are already in the repo. The check runs makepkg (part of pacman) as
#   `nobody`, because it sources the PKGBUILD. Only if something needs building, pull
#   the archlinux image once and start one throwaway container for those repos.
# - In that container (--build <owner/repo>...): install base-devel and git, build each
#   repo as an unprivileged user (makepkg refuses root), and add the packages with
#   repo-add. The repo is only cloned (shallow) when the PKGBUILD needs local files.
#   Copying and repo-add run as the container's root, so the repo files stay root-owned
#   on the host.
set -uo pipefail

CONFIG="${CONFIG:-/etc/arch-repo-build.conf}"
REPO_DIR="${REPO_DIR:-/srv/arch-pkg-host}"
IMAGE=archlinux:latest
CONTAINER_REPO_DIR=/repo
CONTAINER_SCRIPT=/usr/local/bin/arch-repo-build

# user that runs everything that sources a PKGBUILD (set per mode)
RUN_AS=nobody

as_runner() {
  runuser -u "${RUN_AS}" -- "$@"
}

# prints <owner>/<repo> of a GitHub URL, fails for anything else
github_slug() {
  local url="${1%/}"
  if [[ ! "${url}" =~ ^https?://github\.com/([^/[:space:]]+/[^/[:space:]]+)$ ]]; then
    echo "${url}: not a GitHub repo URL (https://github.com/<owner>/<repo>)" >&2
    return 1
  fi
  echo "${BASH_REMATCH[1]%.git}"
}

# fetches the PKGBUILD of a repo into a new directory owned by RUN_AS, prints the directory
fetch_pkgbuild() {
  local slug="$1" dir
  dir="${workdir}/${slug//\//_}"
  install -d -o "${RUN_AS}" "${dir}" || return 1
  # time limits: a hanging fetch would otherwise keep the service from ever finishing
  if ! as_runner curl -fsSL --connect-timeout 20 --max-time 60 -o "${dir}/PKGBUILD" "https://raw.githubusercontent.com/${slug}/HEAD/PKGBUILD"; then
    echo "${slug}: fetching the PKGBUILD failed" >&2
    return 1
  fi
  echo "${dir}"
}

# prints the package files a PKGBUILD version produces, one path per line
package_list() {
  local slug="$1" dir="$2" list
  if ! list="$(cd "${dir}" && as_runner makepkg --packagelist)" || [ -z "${list}" ]; then
    echo "${slug}: listing the package files failed" >&2
    return 1
  fi
  echo "${list}"
}

# reads package file paths on stdin, prints the names of those not in the repo directory
missing_packages() {
  local repo_dir="$1" pkg
  while read -r pkg; do
    [ -e "${repo_dir}/${pkg##*/}" ] || echo "${pkg##*/}"
  done
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

# host mode: returns 0 if the repo has a version that isn't in the repo yet,
# 1 if it's up to date, 2 on errors
needs_build() {
  local slug="$1" dir list missing
  dir="$(fetch_pkgbuild "${slug}")" || return 2
  list="$(package_list "${slug}" "${dir}")" || return 2
  missing="$(missing_packages "${REPO_DIR}" <<<"${list}")"
  if [ -z "${missing}" ]; then
    echo "${slug}: up to date"
    return 1
  fi
  echo "${slug}: new version: $(tr '\n' ' ' <<<"${missing}")"
  return 0
}

# container mode: builds a repo's packages and adds the new ones to the repo
build_repo() {
  local slug="$1" dir srcinfo list pkg
  local -a packages=() added=()
  local repo_db="${CONTAINER_REPO_DIR}/homelab.db.tar.gz"

  dir="$(fetch_pkgbuild "${slug}")" || return 1
  if ! srcinfo="$(cd "${dir}" && as_runner makepkg --printsrcinfo)"; then
    echo "${slug}: reading the PKGBUILD failed" >&2
    return 1
  fi
  if has_local_sources "${srcinfo}"; then
    dir="${dir}.git"
    if ! as_runner git clone --quiet --depth 1 "https://github.com/${slug}.git" "${dir}"; then
      echo "${slug}: cloning failed" >&2
      return 1
    fi
  fi

  list="$(package_list "${slug}" "${dir}")" || return 1
  mapfile -t packages <<<"${list}"

  echo "${slug}: building"
  # --nodeps: runtime dependencies don't have to be installed in the build container;
  # missing makedepends still fail the build
  if ! (cd "${dir}" && as_runner makepkg --noconfirm --nodeps --cleanbuild --clean); then
    echo "${slug}: build failed" >&2
    return 1
  fi

  # A package file in the repo directory counts as built, so on any failure remove what
  # this run copied; otherwise the next run would skip a package that isn't in the
  # database. Copy under a temporary name first, so nginx never serves a half-written file.
  for pkg in "${packages[@]}"; do
    [ -e "${CONTAINER_REPO_DIR}/${pkg##*/}" ] && continue
    added+=("${CONTAINER_REPO_DIR}/${pkg##*/}")
    if ! install -m 0644 "${pkg}" "${CONTAINER_REPO_DIR}/.${pkg##*/}.part" \
        || ! mv "${CONTAINER_REPO_DIR}/.${pkg##*/}.part" "${CONTAINER_REPO_DIR}/${pkg##*/}"; then
      echo "${slug}: copying ${pkg##*/} into the repo failed" >&2
      rm -f "${CONTAINER_REPO_DIR}/.${pkg##*/}.part" "${added[@]}"
      return 1
    fi
  done
  if [ "${#added[@]}" -eq 0 ]; then
    echo "${slug}: already in the repo"
    return 0
  fi
  # --remove deletes the package files of the versions these replace
  if ! repo-add --remove "${repo_db}" "${added[@]}"; then
    echo "${slug}: repo-add failed" >&2
    rm -f "${added[@]}"
    return 1
  fi
}

run_host() {
  local line slug failed=0
  local -a todo=()

  if [ ! -r "${CONFIG}" ]; then
    echo "${CONFIG} not readable" >&2
    exit 1
  fi

  # The config is read on fd 3, so commands that read stdin can't eat its lines.
  while read -r line <&3; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [ -z "${line}" ] && continue
    slug="$(github_slug "${line}")" || { failed=1; continue; }
    needs_build "${slug}" </dev/null
    case $? in
      0) todo+=("${slug}") ;;
      2) failed=1 ;;
    esac
  done 3< "${CONFIG}"

  if [ "${#todo[@]}" -eq 0 ]; then
    echo "nothing to build"
    exit "${failed}"
  fi

  # One container for all builds; --pull=always fetches the image once per run. Runs
  # can't overlap: docker refuses a second container with the same name. --init passes
  # signals on, so a stopped or timed-out run doesn't leave the container behind.
  docker run --rm --init --name arch-repo-build --pull=always \
    -v "$(realpath "$0"):${CONTAINER_SCRIPT}:ro" \
    -v "${REPO_DIR}:${CONTAINER_REPO_DIR}" \
    "${IMAGE}" timeout 2h bash "${CONTAINER_SCRIPT}" --build "${todo[@]}" || failed=1
  exit "${failed}"
}

run_container() {
  local slug failed=0

  # leftovers of a run that was killed while copying
  rm -f "${CONTAINER_REPO_DIR}"/.*.part

  echo "preparing the build container ..."
  if ! pacman -Syu --noconfirm --needed --noprogressbar base-devel git >/dev/null; then
    echo "installing base-devel and git failed" >&2
    exit 1
  fi
  RUN_AS=builder
  useradd --create-home "${RUN_AS}" || exit 1

  for slug in "$@"; do
    build_repo "${slug}" </dev/null || failed=1
  done
  exit "${failed}"
}

workdir="$(mktemp -d)" || exit 1
chmod 0755 "${workdir}"
trap 'rm -rf "${workdir}"' EXIT

if [ "${1:-}" = "--build" ]; then
  shift
  run_container "$@"
else
  run_host
fi
