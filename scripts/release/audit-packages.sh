#!/usr/bin/env bash
set -Eeuo pipefail

artifacts="${1:?Usage: audit-packages.sh ARTIFACTS_DIR VERSION}"
expected_version="${2:?Debian package version is required}"

shopt -s nullglob
packages=("${artifacts}"/iros2j-*.deb)
((${#packages[@]} > 0))

declare -A seen=()
declare -A path_owner=()
for deb in "${packages[@]}"; do
  package="$(dpkg-deb -f "${deb}" Package)"
  version="$(dpkg-deb -f "${deb}" Version)"
  architecture="$(dpkg-deb -f "${deb}" Architecture)"

  [[ "${package}" =~ ^iros2j-[a-z0-9][a-z0-9+.-]+$ ]]
  [[ "${version}" == "${expected_version}" ]]
  [[ "${architecture}" == "arm64" || "${architecture}" == "all" ]]
  [[ -z "${seen[${package}]:-}" ]]
  seen["${package}"]=1

  if dpkg-deb -f "${deb}" Provides | grep -q 'ros-jazzy-'; then
    echo "False official ROS compatibility in ${deb}" >&2
    exit 1
  fi
  if dpkg-deb -c "${deb}" | grep -Eq '/opt/iros2_0|/usr/lib/iros2-0'; then
    echo "Legacy install path in ${deb}" >&2
    exit 1
  fi
  dpkg-deb -c "${deb}" | grep -q './opt/iros2j/'
  while IFS= read -r installed_path; do
    [[ "${installed_path}" == */ ]] && continue
    if [[ -n "${path_owner[${installed_path}]:-}" ]]; then
      echo "Duplicate package path ${installed_path}: ${path_owner[${installed_path}]} and ${package}" >&2
      exit 1
    fi
    path_owner["${installed_path}"]="${package}"
  done < <(dpkg-deb --fsys-tarfile "${deb}" | tar -tf -)
done

for required in \
  iros2j-ros-core \
  iros2j-ros-base \
  iros2j-common-interfaces \
  iros2j-vision-opencv \
  iros2j-rviz2; do
  [[ -n "${seen[${required}]:-}" ]] || {
    echo "Required package is missing: ${required}" >&2
    exit 1
  }
done

printf 'Audited %s iros2j packages.\n' "${#packages[@]}"
