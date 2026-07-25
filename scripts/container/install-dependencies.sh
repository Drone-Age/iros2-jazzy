#!/usr/bin/env bash
set -Eeuo pipefail

# RTI Connext DDS is proprietary and is not part of the IROS2_0 runtime.
#
# The upstream rosdep rules for the Qt 5 Python bindings still include
# python3-sip-dev, which Debian 13 no longer provides. Install the available
# Qt 5/PySide/SIP build dependencies explicitly and skip the affected
# composite rosdep keys.
apt-get install -y --no-install-recommends \
  libpyside2-dev \
  libshiboken2-dev \
  pyqt5-dev \
  python3-pyqt5 \
  python3-pyqt5.qtsvg \
  python3-pyside2.qtsvg \
  python3-sipbuild \
  qtbase5-dev \
  shiboken2

skip_keys="\
rti-connext-dds-6.0.1 \
python3-vcstool \
python3-pyqt5 \
python3-qt-bindings \
python3-qt5-bindings \
python3-sip"

cd /work
colcon list \
  --packages-up-to ros_base rviz2 \
  --paths-only > /work/selected-paths.txt
mapfile -t selected_paths < /work/selected-paths.txt

rosdep install \
  --from-paths "${selected_paths[@]}" \
  --ignore-src \
  --rosdistro jazzy \
  --os=debian:trixie \
  --as-root apt:false \
  --skip-keys "${skip_keys}" \
  --simulate |
  tee /work/rosdep-plan.txt

rosdep install \
  --from-paths "${selected_paths[@]}" \
  --ignore-src \
  --rosdistro jazzy \
  --os=debian:trixie \
  --as-root apt:false \
  --skip-keys "${skip_keys}" \
  -r -y
