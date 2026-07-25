#!/usr/bin/env bash
set -Eeuo pipefail

dpkg-query -W \
  -f='${Package} ${Version} ${Architecture} ${db:Status-Status}\n' \
  iros2-0

env -i HOME="${HOME}" PATH=/usr/bin:/bin \
  bash --noprofile --norc -c '
    set -e
    test -z "${ROS_DISTRO:-}"
    test "$(command -v ros2)" = /usr/bin/ros2
    ros2 --help >/dev/null
    ros2 pkg prefix ros_base
  '

env -i HOME="${HOME}" PATH=/usr/bin:/bin QT_QPA_PLATFORM=offscreen \
  bash --noprofile --norc -c '
    set -e
    test "$(command -v rviz2)" = /usr/bin/rviz2
    rviz2 --help >/dev/null
  '

env -i HOME="${HOME}" PATH=/usr/bin:/bin \
  bash --noprofile --norc -c '
    set -e
    source /opt/iros2_0/jazzy/setup.bash
    test "$ROS_DISTRO" = jazzy
    test -n "$AMENT_PREFIX_PATH"
  '

test_home="$(mktemp -d)"
trap 'rm -rf -- "${test_home}"' EXIT
HOME="${test_home}" iros2-enable-bash
HOME="${test_home}" iros2-enable-bash
test "$(grep -Fxc '# >>> iros2-0 >>>' "${test_home}/.bashrc")" = 1

/usr/lib/iros2-0/docker-entrypoint.sh ros2 --help >/dev/null

for path in \
  /usr/bin/ros2 \
  /usr/bin/rviz2 \
  /usr/bin/iros2-enable-bash \
  /usr/lib/iros2-0/docker-entrypoint.sh \
  /opt/iros2_0/jazzy/setup.bash; do
  dpkg-query -S "${path}"
done

echo "IROS2_0 v0.1.1 runtime acceptance PASSED."
