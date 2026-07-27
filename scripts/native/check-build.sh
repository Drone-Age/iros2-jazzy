#!/usr/bin/env bash
set -Eeuo pipefail

artifacts="${1:-$HOME/iros2j-native/artifacts}"
log_file="${2:-${artifacts}/logs/native-build.log}"

echo "STATUS"
if [[ -f "${artifacts}/build.ok" ]]; then
  echo "build=complete"
elif [[ -f "${artifacts}/build.failed" ]]; then
  echo "build=failed rc=$(<"${artifacts}/build.failed")"
elif [[ -f "${artifacts}/build.pid" ]] &&
     ps -p "$(<"${artifacts}/build.pid")" >/dev/null 2>&1; then
  echo "build=running"
  ps -p "$(<"${artifacts}/build.pid")" \
    -o pid,etime,stat,%cpu,%mem,args
else
  echo "build=stopped_without_marker"
fi

echo "PROGRESS"
printf 'finished_packages='
grep -c '^Finished <<<' "${log_file}" || true
printf 'failed_packages='
grep -c '^Failed   <<<' "${log_file}" || true
grep -E '^(Finished|Failed|Aborted|Starting)' "${log_file}" |
  tail -n 20 || true

echo "ERRORS"
grep -Ei 'error:|failed <<<|aborted <<<|fatal:' "${log_file}" |
  tail -n 20 || true

echo "RESOURCES"
free -h
df -h /
