#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
install_prefix="${IROS2_INSTALL_PREFIX:-/opt/iros2_0/jazzy}"
output_dir="${IROS2_OUTPUT_DIR:-${repo_root}/artifacts}"
version="${IROS2_VERSION:-$(<"${repo_root}/VERSION")}"

[[ "$(uname -m)" == "aarch64" ]]
source /etc/os-release
[[ "${ID}" == "debian" && "${VERSION_CODENAME}" == "trixie" ]]
test -f "${install_prefix}/setup.bash"

IROS2_INSTALL_PREFIX="${install_prefix}" \
IROS2_OUTPUT_DIR="${output_dir}" \
IROS2_PACKAGING_DIR="${repo_root}/packaging" \
IROS2_ARCH=arm64 \
IROS2_VERSION="${version}" \
BUILD_DATE="${BUILD_DATE:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}" \
VCS_REF="${VCS_REF:-$(git -C "${repo_root}" rev-parse HEAD)}" \
  bash "${repo_root}/scripts/container/build-deb.sh"

echo "Native ARM64 package created in ${output_dir}"

if [[ "${IROS2_CLEAN_AFTER_PACKAGE:-1}" == "1" ]]; then
  workspace="${IROS2_WORKSPACE:-$HOME/iros2_0-native/work}"
  if [[ -d "${workspace}/log" ]]; then
    tar -C "${workspace}" -czf \
      "${output_dir}/native-build-logs_${version}.tar.gz" \
      log
  fi
  bash "${repo_root}/scripts/native/cleanup-build.sh" \
    "${workspace}"
fi
