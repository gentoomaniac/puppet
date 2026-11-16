#!/usr/bin/env bash
# Writes every installed pacman package as a Prometheus metric for the
# node-exporter textfile collector:
#   pacman_package_info{package="docker",version="1:28.5.1-1"} 1
# Usage: package-metrics <output .prom file>

set -euo pipefail

OUTPUT="${1:?usage: package-metrics <output .prom file>}"

# Write next to the target and rename, so node-exporter never reads a half-written file
TMP="$(mktemp "${OUTPUT}.XXXXXX")"
trap 'rm -f "${TMP}"' EXIT

{
  echo '# HELP pacman_package_info Installed pacman package, value is always 1.'
  echo '# TYPE pacman_package_info gauge'
  pacman -Q | awk '{ printf "pacman_package_info{package=\"%s\",version=\"%s\"} 1\n", $1, $2 }'
} > "${TMP}"

# mktemp creates 0600, but node-exporter runs as nobody
chmod 0644 "${TMP}"
mv "${TMP}" "${OUTPUT}"
