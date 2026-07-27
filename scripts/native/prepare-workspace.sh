#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workspace="${1:-$HOME/iros2j-native/work}"
lock_file="${2:-${repo_root}/manifests/iros2j-jazzy.lock.repos}"

test -f "${lock_file}" || {
  echo "Locked source manifest is missing: ${lock_file}" >&2
  echo "Create and review it with scripts/native/lock-sources.sh first." >&2
  exit 1
}
command -v vcs >/dev/null

mkdir -p "${workspace}/src"
vcs import --input "${lock_file}" "${workspace}/src"

vcs export --exact "${workspace}/src" > "${workspace}/resolved.repos"
python3 - "${lock_file}" "${workspace}/resolved.repos" <<'PY'
import sys
from pathlib import Path
import yaml

expected = yaml.safe_load(Path(sys.argv[1]).read_text(encoding="utf-8"))
actual = yaml.safe_load(Path(sys.argv[2]).read_text(encoding="utf-8"))
if expected != actual:
    raise SystemExit("workspace revisions differ from the committed lock manifest")
PY

printf 'Prepared exact iros2j source workspace: %s\n' "${workspace}"
