#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workspace="${IROS2_WORKSPACE:-$HOME/iros2j-native/work}"
artifacts="${IROS2_OUTPUT_DIR:-${repo_root}/artifacts}"
install_base="${IROS2_INSTALL_BASE:-${workspace}/install}"
release_log="${artifacts}/native-release.log"
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-$(git -C "${repo_root}" show -s --format=%ct HEAD)}"

mkdir -p "${artifacts}"
printf 'FAIL\n' > "${artifacts}/status.txt"

exec > >(tee -a "${release_log}") 2>&1

echo "iros2j native release started at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Repository: ${repo_root}"
echo "Workspace: ${workspace}"
echo "Artifacts: ${artifacts}"
echo "Isolated install base: ${install_base}"

if [[ "${IROS2_INSTALL_DEPENDENCIES:-0}" == "1" ]]; then
  echo "Stage: bootstrap native host"
  bash "${repo_root}/scripts/native/bootstrap-host.sh"
fi
export IROS2_VENV_BIN="${IROS2_VENV_BIN:-$HOME/iros2j-native/.venv/bin}"
export PATH="${IROS2_VENV_BIN}:${PATH}"

echo "Stage: prepare exact source workspace"
bash "${repo_root}/scripts/native/prepare-workspace.sh" "${workspace}"

if [[ "${IROS2_INSTALL_DEPENDENCIES:-0}" == "1" ]]; then
  echo "Stage: install dependencies"
  bash "${repo_root}/scripts/native/install-dependencies.sh" \
    "${workspace}" "${artifacts}"
fi

echo "Stage: build ROS"
bash "${repo_root}/scripts/native/build-rpi.sh" \
  "${workspace}" \
  "${install_base}" \
  "${artifacts}"

echo "Stage: build Debian package"
IROS2_WORKSPACE="${workspace}" \
IROS2_OUTPUT_DIR="${artifacts}" \
IROS2_INSTALL_BASE="${install_base}" \
  bash "${repo_root}/scripts/native/build-package.sh"

echo "Stage: audit Debian packages"
bash "${repo_root}/scripts/release/audit-packages.sh" \
  "${artifacts}" \
  "$(<"${repo_root}/VERSION")-1+deb13"

echo "Stage: build signed APT repository"
IROS2_OUTPUT_DIR="${artifacts}" \
  bash "${repo_root}/scripts/release/build-apt-repository.sh"

echo "Stage: generate SPDX SBOM"
python3 "${repo_root}/scripts/release/generate-sbom.py" \
  --inventory "${artifacts}/package-inventory.json" \
  --artifacts "${artifacts}" \
  --output "${artifacts}/iros2j-$(<"${repo_root}/VERSION").spdx.json"

echo "Stage: install and smoke-test APT snapshot"
bash "${repo_root}/scripts/release/verify-native.sh" \
  "${artifacts}/iros2j-apt_trixie_arm64.tar.gz" |
  tee "${artifacts}/install-smoke-test.txt"

printf 'PASS\n' > "${artifacts}/status.txt"

echo "Artifacts:"
ls -lh \
  "${artifacts}"/iros2j-*.deb \
  "${artifacts}"/SHA256SUMS \
  "${artifacts}"/iros2j-apt_trixie_arm64.tar.gz* \
  "${artifacts}"/iros2j-*.spdx.json

echo "iros2j native release completed at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
