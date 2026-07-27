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
  contents="$(dpkg-deb -c "${deb}")"
  if grep -Eq '/opt/iros2_0|/usr/lib/iros2-0' <<<"${contents}"; then
    echo "Legacy install path in ${deb}" >&2
    exit 1
  fi
  grep -q './opt/iros2j/' <<<"${contents}"
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
  iros2j-fastcdr \
  iros2j-fastrtps \
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

for rmw_package in \
  iros2j-rmw-fastrtps-cpp \
  iros2j-rmw-fastrtps-dynamic-cpp \
  iros2j-rmw-fastrtps-shared-cpp; do
  rmw_deb=("${artifacts}/${rmw_package}_${expected_version}"_*.deb)
  ((${#rmw_deb[@]} == 1)) || {
    echo "Expected exactly one ${rmw_package} package." >&2
    exit 1
  }
  dependencies="$(dpkg-deb -f "${rmw_deb[0]}" Depends)"
  grep -Fq "iros2j-fastcdr (= ${expected_version})" <<<"${dependencies}"
  grep -Fq "iros2j-fastrtps (= ${expected_version})" <<<"${dependencies}"
  if grep -Eq '(^|, ?)(libfastcdr-dev|libfastrtps-dev)(,|$)' <<<"${dependencies}"; then
    echo "Host Fast DDS development dependency leaked into ${rmw_package}." >&2
    exit 1
  fi
done

printf 'Audited %s iros2j packages.\n' "${#packages[@]}"
