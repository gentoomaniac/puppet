#!/usr/bin/env bash
# ExecStopPost of every `timer` service: writes the outcome of the run that just
# ended to <textfile dir>/timer_<unit>.prom for node-exporter's textfile collector.
# systemd passes the result in SERVICE_RESULT and the main process' exit in EXIT_CODE
# and EXIT_STATUS. Age of the last run in PromQL:
#   time() - systemd_timer_last_success_timestamp_seconds
# Usage: timer-metrics <unit> <textfile dir>

set -euo pipefail

UNIT="${1:?usage: timer-metrics <unit> <textfile dir>}"
OUTPUT="${2:?usage: timer-metrics <unit> <textfile dir>}/timer_${UNIT}.prom"

show() { systemctl show --property="$1" --value --timestamp=unix "${UNIT}.service"; }

# 0 / empty when the main process never started (e.g. a failing ExecStartPre)
START="$(show ExecMainStartTimestamp)"
START="${START#@}"
START_US="$(show ExecMainStartTimestampMonotonic)"
EXIT_US="$(show ExecMainExitTimestampMonotonic)"

if [ "${SERVICE_RESULT:-}" = success ]; then
  SUCCESS=1
  LAST_SUCCESS="$(date +%s)"
else
  SUCCESS=0
  # keep the last success of an earlier run
  LAST_SUCCESS="$(sed -n 's/^systemd_timer_last_success_timestamp_seconds{[^}]*} //p' "${OUTPUT}" 2>/dev/null || true)"
fi

# exit status of the main process; killed by a signal: 128 + its number, like a shell;
# empty when it never ran
case "${EXIT_CODE:-}" in
  exited) EXIT_STATUS_VALUE="${EXIT_STATUS:-}" ;;
  killed | dumped) EXIT_STATUS_VALUE="$(( 128 + $(kill -l "${EXIT_STATUS:-0}" 2>/dev/null || echo 0) ))" ;;
  *) EXIT_STATUS_VALUE='' ;;
esac
[[ "${EXIT_STATUS_VALUE}" =~ ^[0-9]+$ ]] || EXIT_STATUS_VALUE=''

LABELS="unit=\"${UNIT}\""
TMP="$(mktemp "${OUTPUT}.XXXXXX")"
trap 'rm -f "${TMP}"' EXIT

{
  echo '# HELP systemd_timer_last_run_success Whether the last run of the timer service succeeded.'
  echo '# TYPE systemd_timer_last_run_success gauge'
  echo "systemd_timer_last_run_success{${LABELS}} ${SUCCESS}"
  if [ -n "${START}" ] && [ "${START_US:-0}" -gt 0 ] && [ "${EXIT_US:-0}" -ge "${START_US}" ]; then
    echo '# HELP systemd_timer_last_run_start_timestamp_seconds Start of the last run.'
    echo '# TYPE systemd_timer_last_run_start_timestamp_seconds gauge'
    echo "systemd_timer_last_run_start_timestamp_seconds{${LABELS}} ${START}"
    echo '# HELP systemd_timer_last_run_duration_seconds Duration of the last run.'
    echo '# TYPE systemd_timer_last_run_duration_seconds gauge'
    awk -v s="${START_US}" -v e="${EXIT_US}" -v l="${LABELS}" \
      'BEGIN { printf "systemd_timer_last_run_duration_seconds{%s} %.3f\n", l, (e - s) / 1000000 }'
  fi
  if [ -n "${EXIT_STATUS_VALUE}" ]; then
    echo '# HELP systemd_timer_last_run_exit_status Exit status of the last run (128 + signal number when killed).'
    echo '# TYPE systemd_timer_last_run_exit_status gauge'
    echo "systemd_timer_last_run_exit_status{${LABELS}} ${EXIT_STATUS_VALUE}"
  fi
  if [ -n "${LAST_SUCCESS}" ]; then
    echo '# HELP systemd_timer_last_success_timestamp_seconds End of the last successful run.'
    echo '# TYPE systemd_timer_last_success_timestamp_seconds gauge'
    echo "systemd_timer_last_success_timestamp_seconds{${LABELS}} ${LAST_SUCCESS}"
  fi
} > "${TMP}"

# mktemp creates 0600, but node-exporter runs as nobody
chmod 0644 "${TMP}"
mv "${TMP}" "${OUTPUT}"
