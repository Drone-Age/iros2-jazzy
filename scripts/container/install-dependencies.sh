#!/usr/bin/env bash
set -Eeuo pipefail

# RTI Connext DDS is proprietary and is not part of the IROS2_0 runtime.
skip_keys="rti-connext-dds-6.0.1 python3-vcstool"

rosdep install \
  --from-paths /work/src \
  --ignore-src \
  --rosdistro jazzy \
  --os=debian:trixie \
  --as-root apt:false \
  --skip-keys "${skip_keys}" \
  --simulate |
  tee /work/rosdep-plan.txt

rosdep install \
  --from-paths /work/src \
  --ignore-src \
  --rosdistro jazzy \
  --os=debian:trixie \
  --as-root apt:false \
  --skip-keys "${skip_keys}" \
  -r -y
