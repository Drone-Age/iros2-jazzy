#!/usr/bin/env bash
set -Eeuo pipefail

workspace="${1:-$HOME/iros2_0-native/work}"
install_base="${2:-/opt/iros2_0/jazzy}"
artifacts="${3:-$HOME/iros2_0-native/artifacts}"
venv_bin="${IROS2_VENV_BIN:-}"

cd "${workspace}"
mkdir -p "${artifacts}"
rm -f "${artifacts}/build.ok" "${artifacts}/build.failed"
if [[ -n "${venv_bin}" ]]; then
  export PATH="${venv_bin}:${PATH}"
elif [[ -x "$HOME/iros2_0-native/.venv/bin/vcs" ]]; then
  export PATH="$HOME/iros2_0-native/.venv/bin:${PATH}"
fi

command -v vcs >/dev/null

selection_args=(--packages-up-to ros_base rviz2)
if [[ "${IROS2_RESUME_BUILD:-1}" == "1" ]]; then
  selection_args=(--packages-skip-build-finished "${selection_args[@]}")
fi

cmake_cache_args=()
if [[ "${IROS2_CMAKE_CLEAN_CACHE:-0}" == "1" ]]; then
  cmake_cache_args=(--cmake-clean-cache)
fi

on_exit() {
  local result=$?
  if (( result != 0 )); then
    printf '%s\n' "${result}" > "${artifacts}/build.failed"
  fi
}
trap on_exit EXIT

colcon build \
  --executor parallel \
  --parallel-workers "${IROS2_PARALLEL_WORKERS:-2}" \
  "${selection_args[@]}" \
  "${cmake_cache_args[@]}" \
  --install-base "${install_base}" \
  --cmake-args \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF

test -f "${install_base}/setup.bash"
env -i HOME="${HOME}" PATH="/usr/bin:/bin" \
  bash --noprofile --norc -c "
    source '${install_base}/setup.bash'
    ros2 pkg prefix ros_base
    ros2 pkg prefix rviz2
  "

touch "${artifacts}/build.ok"
