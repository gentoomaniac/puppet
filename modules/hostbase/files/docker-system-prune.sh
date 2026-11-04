#!/usr/bin/env bash
if [ ! -f /etc/no_prune ]; then
  sleep $((RANDOM%60*60))
  yes | docker system prune --volumes
fi
