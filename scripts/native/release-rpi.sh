#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workspace="${IROS2_WORKSPACE:-$HOME/iros2_0-native/work}"
artifacts="${IROS2_OUTPUT_DIR:-${repo_root}/artifacts}"
install_prefix="${IROS2_INSTALL_PREFIX:-${workspace}/install}"
release_log="${artifacts}/native-release.log"

mkdir -p "${artifacts}"

exec > >(tee -a "${release_log}") 2>&1

echo "IROS2_0 native release started at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Repository: ${repo_root}"
echo "Workspace: ${workspace}"
echo "Artifacts: ${artifacts}"
echo "Install prefix: ${install_prefix}"

if [[ "${IROS2_INSTALL_DEPENDENCIES:-0}" == "1" ]]; then
  echo "Stage: install dependencies"
  bash "${repo_root}/scripts/native/install-dependencies.sh" \
    "${workspace}" "${artifacts}"
fi

echo "Stage: build ROS"
bash "${repo_root}/scripts/native/build-rpi.sh" \
  "${workspace}" \
  "${install_prefix}" \
  "${artifacts}"

echo "Stage: build Debian package"
IROS2_WORKSPACE="${workspace}" \
IROS2_OUTPUT_DIR="${artifacts}" \
IROS2_INSTALL_PREFIX="${install_prefix}" \
  bash "${repo_root}/scripts/native/build-package.sh"

echo "Artifacts:"
ls -lh \
  "${artifacts}"/iros2-0_*.deb \
  "${artifacts}"/SHA256SUMS \
  "${artifacts}"/iros2-0_latest_arm64.deb.sha256

echo "IROS2_0 native release completed at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
