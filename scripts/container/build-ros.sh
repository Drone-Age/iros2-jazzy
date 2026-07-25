#!/usr/bin/env bash
set -Eeuo pipefail

cd /work
colcon build \
  --install-base /opt/iros2_0/jazzy \
  --executor sequential \
  --packages-up-to ros_base rviz2 \
  --cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF

test -f /opt/iros2_0/jazzy/setup.bash
find /opt/iros2_0/jazzy -type f -name 'librcutils.so*' -print -quit | grep -q .
test -x /opt/iros2_0/jazzy/rviz2/bin/rviz2
