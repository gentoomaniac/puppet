#!/usr/bin/env bash
set -euo pipefail

if [ -e /etc/no_reboot ]; then
  exit 0
fi

# a running oneshot reports "activating", which `systemctl is-active` doesn't count
case "$(systemctl show -p ActiveState --value pacman-update.service)" in
  active|activating|reloading)
    echo "upgrade in progress, not rebooting"
    exit 0
    ;;
esac
if [ -e /var/lib/pacman/db.lck ]; then
  echo "pacman database locked, not rebooting"
  exit 0
fi

min_uptime_seconds=$((7 * 24 * 3600))
uptime_seconds=$(cut -d. -f1 /proc/uptime)

if [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
  echo "running kernel was upgraded, rebooting"
  reboot
elif [ "${uptime_seconds}" -ge "${min_uptime_seconds}" ]; then
  echo "uptime ${uptime_seconds}s >= ${min_uptime_seconds}s, rebooting"
  reboot
else
  echo "no reboot needed"
fi
