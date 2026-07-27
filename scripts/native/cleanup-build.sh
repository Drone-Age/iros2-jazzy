#!/usr/bin/env bash
set -Eeuo pipefail

workspace="${1:-$HOME/iros2j-native/work}"
workspace="$(realpath -m "${workspace}")"
allowed_root="$(realpath -m "$HOME/iros2j-native")"

case "${workspace}" in
  "${allowed_root}"/*) ;;
  *)
    echo "Refusing cleanup outside ${allowed_root}: ${workspace}" >&2
    exit 1
    ;;
esac

for directory in "${workspace}/build" "${workspace}/log"; do
  if [[ -d "${directory}" ]]; then
    rm -rf -- "${directory}"
    echo "Removed ${directory}"
  fi
done

find "${workspace}" \
  -type f \
  \( -name '*.pyc' -o -name '*.pyo' \) \
  -delete
find "${workspace}" \
  -type d \
  -name __pycache__ \
  -empty \
  -delete

echo "Native build intermediates removed."
