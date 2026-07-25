#!/usr/bin/env bash
set -Eeuo pipefail

workspace="${1:-$HOME/iros2_0-native/work}"
artifacts="${2:-$HOME/iros2_0-native/artifacts}"

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

cd "${workspace}"
mkdir -p "${artifacts}"

colcon list \
  --packages-up-to ros_base rviz2 \
  --paths-only > "${artifacts}/selected-paths.txt"

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
  as_root rosdep init
fi
rosdep update

# Debian 13 uses Qt 5 / PySide 2 package names that are not fully covered by
# the upstream Jazzy rosdep rules.
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
  libpyside2-dev \
  libshiboken2-dev \
  pyqt5-dev \
  python3-colcon-bash \
  python3-colcon-package-information \
  python3-colcon-parallel-executor \
  python3-pyqt5 \
  python3-pyqt5.qtsvg \
  python3-pyside2.qtsvg \
  python3-sipbuild \
  qtbase5-dev \
  shiboken2

mapfile -t selected_paths < "${artifacts}/selected-paths.txt"
rosdep install \
  --from-paths "${selected_paths[@]}" \
  --ignore-src \
  --rosdistro jazzy \
  --os=debian:trixie \
  --skip-keys "rti-connext-dds-6.0.1 python3-vcstool python3-pyqt5 python3-qt-bindings python3-qt5-bindings python3-sip" \
  -y
