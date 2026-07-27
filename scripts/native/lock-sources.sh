#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workspace="${1:-$HOME/iros2j-native/work}"
upstream_url="$(<"${repo_root}/manifests/ros2-jazzy-upstream.url")"
lock_file="${2:-${repo_root}/manifests/iros2j-jazzy.lock.repos}"

command -v curl >/dev/null
command -v vcs >/dev/null
command -v git >/dev/null

mkdir -p "${workspace}/src"
curl --fail --location --silent --show-error \
  "${upstream_url}" \
  --output "${workspace}/ros2.repos"
vcs import --input "${workspace}/ros2.repos" "${workspace}/src"

variants="${workspace}/src/ros2/variants"
if [[ ! -d "${variants}/.git" ]]; then
  git clone --branch jazzy \
    https://github.com/ros2/variants.git \
    "${variants}"
fi

vision_opencv="${workspace}/src/ros-perception/vision_opencv"
if [[ ! -d "${vision_opencv}/.git" ]]; then
  git clone --branch 4.1.0 \
    https://github.com/ros-perception/vision_opencv.git \
    "${vision_opencv}"
fi

temporary="${lock_file}.tmp"
vcs export --exact "${workspace}/src" > "${temporary}"
python3 - "${temporary}" <<'PY'
import sys
from pathlib import Path
import yaml

path = Path(sys.argv[1])
data = yaml.safe_load(path.read_text(encoding="utf-8"))
repositories = data.get("repositories", {})
if not repositories:
    raise SystemExit("locked source manifest contains no repositories")
for name, repository in repositories.items():
    version = repository.get("version", "")
    if len(version) != 40 or any(c not in "0123456789abcdef" for c in version):
        raise SystemExit(f"{name}: version is not an exact lowercase commit SHA")
path.write_text(yaml.safe_dump(data, sort_keys=True), encoding="utf-8")
PY
mv -- "${temporary}" "${lock_file}"
printf 'Locked %s repositories in %s\n' \
  "$(grep -c '^  [^ ].*:$' "${lock_file}")" \
  "${lock_file}"
