#!/usr/bin/env bash
set -Eeuo pipefail

cd /work
colcon build \
  --merge-install \
  --install-base /opt/iros2_0/jazzy \
  --executor sequential \
  --cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF

test -f /opt/iros2_0/jazzy/setup.bash
