#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
install_base="${IROS2_INSTALL_BASE:-$HOME/iros2j-native/work/install}"
output_dir="${IROS2_OUTPUT_DIR:-${repo_root}/artifacts}"
version="${IROS2_VERSION:-$(<"${repo_root}/VERSION")}"

[[ "$(uname -m)" == "aarch64" ]]
source /etc/os-release
[[ "${ID}" == "debian" && "${VERSION_CODENAME}" == "trixie" ]]
test -f "${install_base}/setup.bash"
test -f "${output_dir}/build.ok"

IROS2_INSTALL_BASE="${install_base}" \
IROS2_OUTPUT_DIR="${output_dir}" \
IROS2_VERSION="${version}" \
  bash "${repo_root}/scripts/native/build-debs.sh"

echo "Native ARM64 package created in ${output_dir}"

if [[ "${IROS2_CLEAN_AFTER_PACKAGE:-1}" == "1" ]]; then
  workspace="${IROS2_WORKSPACE:-$HOME/iros2j-native/work}"
  if [[ -d "${workspace}/log" ]]; then
    tar -C "${workspace}" -czf \
      "${output_dir}/native-build-logs_${version}.tar.gz" \
      log
  fi
  bash "${repo_root}/scripts/native/cleanup-build.sh" \
    "${workspace}"
fi
