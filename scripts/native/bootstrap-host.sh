#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
venv="${IROS2_VENV:-$HOME/iros2j-native/.venv}"

as_root() {
  if ((EUID == 0)); then "$@"; else sudo "$@"; fi
}

source /etc/os-release
[[ "$(uname -m)" == "aarch64" ]]
[[ "${ID}" == "debian" && "${VERSION_CODENAME}" == "trixie" ]]

as_root apt-get update
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apt-utils \
  build-essential \
  ca-certificates \
  cmake \
  curl \
  dpkg-dev \
  fakeroot \
  git \
  gnupg \
  ninja-build \
  python3-colcon-bash \
  python3-colcon-cmake \
  python3-colcon-core \
  python3-colcon-output \
  python3-colcon-package-information \
  python3-colcon-package-selection \
  python3-colcon-parallel-executor \
  python3-colcon-python-setup-py \
  python3-colcon-recursive-crawl \
  python3-colcon-ros \
  python3-colcon-test-result \
  python3-pip \
  python3-rosdep2 \
  python3-setuptools \
  python3-venv \
  python3-yaml

python3 -m venv --system-site-packages "${venv}"
"${venv}/bin/pip" install --requirement "${repo_root}/requirements-build.txt"
printf 'Native Debian 13 ARM64 host bootstrapped: %s\n' "${venv}"
