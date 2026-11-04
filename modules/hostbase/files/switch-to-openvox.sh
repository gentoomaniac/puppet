#!/usr/bin/env bash
# TEMPORARY: replace Arch's puppet/facter packages with openvox/openfact.
#
# Started by hostbase::puppet through systemd-run, so it runs outside the
# puppet process whose files it replaces. It pauses the puppet timer, waits
# for the current run to finish and swaps the packages in one pacman transaction:
# --ask=4 answers "yes" to removing the conflicting puppet/facter, and if the
# transaction fails nothing is removed.
set -euo pipefail

if pacman -Qq openvox >/dev/null 2>&1; then
  echo "openvox is already installed"
  exit 0
fi

busy() {
  pgrep -f '/usr/bin/puppet( |$)' >/dev/null || [ -e /var/lib/pacman/db.lck ]
}

# no new puppet runs from here on; the trap restarts the timer however we exit
trap 'systemctl start run-puppet.timer' EXIT
systemctl stop run-puppet.timer

# wait up to 30 minutes for the running puppet apply (or pacman) to finish
for _ in $(seq 1 180); do
  busy || break
  sleep 10
done
if busy; then
  echo "puppet or pacman still running after 30 minutes, giving up; the next puppet run retries"
  exit 1
fi

pacman -S --noconfirm --needed --ask=4 openvox openfact
echo "switched to openvox: $(/usr/bin/puppet --version || true)"
