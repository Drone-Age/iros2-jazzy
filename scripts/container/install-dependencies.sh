#!/usr/bin/env bash
set -Eeuo pipefail

rosdep install \
  --from-paths /work/src \
  --ignore-src \
  --rosdistro jazzy \
  --os=debian:trixie \
  --as-root apt:false \
  --simulate |
  tee /work/rosdep-plan.txt

rosdep install \
  --from-paths /work/src \
  --ignore-src \
  --rosdistro jazzy \
  --os=debian:trixie \
  --as-root apt:false \
  -r -y
