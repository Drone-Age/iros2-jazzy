#!/usr/bin/env bash
set -Eeuo pipefail

repo="${IROS2_GITHUB_REPO:-Drone-Age/iros2_0}"
tag="${IROS2_RELEASE_TAG:-}"
verify_installed_only="${IROS2_VERIFY_INSTALLED_ONLY:-0}"
if [[ "${verify_installed_only}" != "1" && -z "${tag}" ]]; then
  echo "Set IROS2_RELEASE_TAG, for example v0.1.0." >&2
  exit 1
fi
version="${IROS2_PACKAGE_VERSION:-${tag#v}-1+deb13}"
allow_remove_prefix="${IROS2_ALLOW_REMOVE_PREFIX:-0}"
asset="iros2-0_${version}_arm64.deb"
release_url="https://github.com/${repo}/releases/download/${tag}"
work_dir="$(mktemp -d)"
trap 'rm -rf -- "${work_dir}"' EXIT

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

clean_shell() {
  env -i \
    HOME="${HOME}" \
    USER="${USER:-$(id -un)}" \
    LOGNAME="${LOGNAME:-$(id -un)}" \
    SHELL=/bin/bash \
    TERM="${TERM:-dumb}" \
    DISPLAY="${DISPLAY:-}" \
    XAUTHORITY="${XAUTHORITY:-}" \
    WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-}" \
    XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-}" \
    DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-}" \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    bash --noprofile --norc -c "$1"
}

[[ "$(uname -m)" == "aarch64" ]]
source /etc/os-release
[[ "${ID}" == "debian" && "${VERSION_CODENAME}" == "trixie" ]]

if [[ "${verify_installed_only}" != "1" ]]; then
  curl -fL "${release_url}/${asset}" -o "${work_dir}/${asset}"
  curl -fL "${release_url}/SHA256SUMS" -o "${work_dir}/SHA256SUMS"
(
  cd "${work_dir}"
    awk -v asset="${asset}" '
      $2 == asset || $2 == "./" asset {print $1 "  " asset}
    ' SHA256SUMS | sha256sum -c -
  )

  if dpkg-query -W -f='${db:Status-Status}' iros2-0 2>/dev/null |
     grep -q '^installed$'; then
    as_root apt-get purge -y iros2-0
  fi

  if [[ -e /opt/iros2_0/jazzy ]]; then
    if [[ "${allow_remove_prefix}" != "1" ]]; then
      echo "/opt/iros2_0/jazzy remains outside dpkg control." >&2
      echo "Use a clean target or set IROS2_ALLOW_REMOVE_PREFIX=1 explicitly." >&2
      exit 1
    fi
    as_root rm -rf -- /opt/iros2_0/jazzy
  fi

  as_root apt-get update
  as_root apt-get install -y "${work_dir}/${asset}"
fi

dpkg-query -W -f='${Package} ${Version} ${Architecture} ${db:Status-Status}\n' \
  iros2-0

# Package-owned wrappers must work without an inherited ROS environment.
clean_shell '
  set -e
  test -z "${ROS_DISTRO:-}"
  test "$(command -v ros2)" = /usr/bin/ros2
  ros2 --help >/dev/null
  ros2 pkg prefix ros_base
  ros2 doctor --report >/dev/null
'

clean_shell '
  set -e
  source /opt/iros2_0/jazzy/setup.bash
  test "$ROS_DISTRO" = jazzy
  command -v colcon >/dev/null
'

echo "IROS2_0 native release verification PASSED."
