#!/usr/bin/env bash
# Removes orphans: packages installed only as dependencies that nothing requires or
# optionally requires anymore (pacman -Qdtq). Packages Puppet installs are explicit,
# so they are never orphans. /etc/no_orphan_cleanup turns it off on a host.

set -euo pipefail

[ -f /etc/no_orphan_cleanup ] && exit 0

# don't collide with a Puppet run or pacman-update holding the database lock; wait up to 10 min
for _ in $(seq 60); do
  [ -e /var/lib/pacman/db.lck ] || break
  sleep 10
done

# removing orphans can orphan their dependencies, so repeat until none are left
for _ in $(seq 5); do
  # -Qdtq exits 1 when there are no orphans
  mapfile -t orphans < <(pacman -Qdtq || true)
  [ "${#orphans[@]}" -eq 0 ] && exit 0
  echo "removing orphans: ${orphans[*]}"
  pacman -Rns --noconfirm "${orphans[@]}"
done
echo "orphans left after 5 rounds: $(pacman -Qdtq | tr '\n' ' ')"
