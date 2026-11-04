#!/usr/bin/env bash
if [ ! -f /etc/no_paccache ]; then
  sleep $((RANDOM%60*60))
  # keep the last 2 versions of installed packages, drop uninstalled ones
  paccache -r -k2
  paccache -r -u -k0
fi
