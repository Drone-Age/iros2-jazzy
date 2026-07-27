#!/usr/bin/env bash
set -Eeuo pipefail

install_base="${1:-$HOME/iros2j-native/work/install}"

# shellcheck disable=SC1091
set +u
source "${install_base}/setup.bash"
set -u

[[ "${ROS_DISTRO:-}" == "jazzy" ]]
command -v ros2
command -v rviz2
ros2 pkg prefix ros_base
ros2 pkg prefix rviz2
ros2 pkg prefix vision_opencv
ros2 --help >/dev/null
QT_QPA_PLATFORM=offscreen rviz2 --help >/dev/null
