#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
version="${IROS2_PACKAGE_VERSION:-$(<"${repo_root}/VERSION")}"
tag="${IROS2_RELEASE_TAG:-v2.${version}}"
repository="${IROS2_REPOSITORY:-Drone-Age/iros2_0}"
archive="${1:-}"

[[ "$(uname -m)" == "aarch64" ]]
source /etc/os-release
[[ "${ID}" == "debian" && "${VERSION_CODENAME}" == "trixie" ]]

as_root() {
  if ((EUID == 0)); then "$@"; else sudo "$@"; fi
}

temporary="$(mktemp -d /tmp/iros2j-verify.XXXXXX)"
source_list="/etc/apt/sources.list.d/iros2j.list"
keyring="/usr/share/keyrings/iros2j-archive-keyring.gpg"
previous_source="${temporary}/previous-iros2j.list"
previous_keyring="${temporary}/previous-iros2j-archive-keyring.gpg"

if as_root test -f "${source_list}"; then
  as_root cp -a "${source_list}" "${previous_source}"
fi
if as_root test -f "${keyring}"; then
  as_root cp -a "${keyring}" "${previous_keyring}"
fi

cleanup() {
  as_root rm -f -- "${source_list}" "${keyring}"
  if [[ -f "${previous_source}" ]]; then
    as_root install -m 0644 "${previous_source}" "${source_list}"
  fi
  if [[ -f "${previous_keyring}" ]]; then
    as_root install -m 0644 "${previous_keyring}" "${keyring}"
  fi
  rm -rf -- "${temporary}"
}
trap cleanup EXIT

if [[ -z "${archive}" ]]; then
  archive="${temporary}/iros2j-apt_trixie_arm64.tar.gz"
  curl --fail --location \
    "https://github.com/${repository}/releases/download/${tag}/iros2j-apt_trixie_arm64.tar.gz" \
    --output "${archive}"
  curl --fail --location \
    "https://github.com/${repository}/releases/download/${tag}/iros2j-apt_trixie_arm64.tar.gz.sha256" \
    --output "${archive}.sha256"
fi

archive="$(realpath "${archive}")"
if [[ -f "${archive}.sha256" ]]; then
  (cd "$(dirname "${archive}")" && sha256sum -c "$(basename "${archive}").sha256")
fi
tar -C "${temporary}" -xzf "${archive}"
apt_root="${temporary}/apt-repository"
chmod 0755 "${temporary}"
chmod -R a+rX "${apt_root}"
gpg --dearmor < "${apt_root}/iros2j-archive-keyring.asc" \
  > "${temporary}/iros2j-archive-keyring.gpg"
as_root install -m 0644 "${temporary}/iros2j-archive-keyring.gpg" \
  "${keyring}"
printf 'deb [arch=arm64 signed-by=/usr/share/keyrings/iros2j-archive-keyring.gpg] file:%s trixie main\n' \
  "${apt_root}" |
  as_root tee "${source_list}" >/dev/null

as_root apt-get update
if dpkg-query -W -f='${db:Status-Status}' iros2-0 2>/dev/null |
  grep -q '^installed$'; then
  as_root apt-get purge -y iros2-0
fi
as_root apt-get install -y \
  iros2j-ros-base \
  iros2j-vision-opencv \
  iros2j-rviz2

env -i HOME="${HOME}" PATH="/usr/bin:/bin" \
  bash --noprofile --norc -e -c '
    source /opt/iros2j/setup.bash
    test "${ROS_DISTRO}" = jazzy
    ros2 pkg prefix ros_core
    ros2 pkg prefix ros_base
    ros2 pkg prefix vision_opencv
    ros2 pkg prefix rviz2
    ros2 --help >/dev/null
    QT_QPA_PLATFORM=offscreen rviz2 --help >/dev/null
  '

printf 'Clean iros2j APT installation verified for %s (%s).\n' "${version}" "${tag}"
