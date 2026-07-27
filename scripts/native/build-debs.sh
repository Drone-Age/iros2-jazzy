#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
install_base="${IROS2_INSTALL_BASE:-$HOME/iros2j-native/work/install}"
output_dir="${IROS2_OUTPUT_DIR:-${repo_root}/artifacts}"
product_version="${IROS2_VERSION:-$(<"${repo_root}/VERSION")}"
debian_revision="${IROS2_DEBIAN_REVISION:-1}"
debian_version="${product_version}-${debian_revision}+deb13"
manifest="${output_dir}/package-inventory.json"

[[ "$(uname -m)" == "aarch64" ]]
source /etc/os-release
[[ "${ID}" == "debian" && "${VERSION_CODENAME}" == "trixie" ]]
test -d "${install_base}"
mkdir -p "${output_dir}"

python3 "${repo_root}/scripts/package_metadata.py" \
  --install-base "${install_base}" \
  --version "${debian_version}" \
  --output "${manifest}"

cleanup_roots=()
cleanup() {
  local root
  for root in "${cleanup_roots[@]}"; do
    rm -rf -- "${root}"
  done
}
trap cleanup EXIT

mapfile -t package_rows < <(
  python3 - "${manifest}" <<'PY'
import json
import sys
for package in json.load(open(sys.argv[1], encoding="utf-8"))["packages"]:
    print("|".join([
        package["ros_name"],
        package["debian_name"],
        package["architecture"],
        package["prefix"],
        ", ".join(package["dependencies"]),
        " ".join(package["external_dependencies"]),
    ]))
PY
)

for row in "${package_rows[@]}"; do
  IFS='|' read -r ros_name deb_name architecture source_prefix internal_depends external_keys <<<"${row}"
  package_root="$(mktemp -d "/tmp/${deb_name}.${architecture}.XXXXXX")"
  cleanup_roots+=("${package_root}")
  mkdir -p \
    "${package_root}/DEBIAN" \
    "${package_root}/opt/iros2j/${ros_name}"

  cp -a "${source_prefix}/." "${package_root}/opt/iros2j/${ros_name}/"

  # colcon generates aggregate setup files at install-base level. ros_environment
  # owns them in the Debian distribution so no two packages claim the same path.
  if [[ "${ros_name}" == "ros_environment" ]]; then
    mkdir -p "${package_root}/etc/profile.d"
    find "${install_base}" -maxdepth 1 -type f \
      \( -name 'setup.*' -o -name 'local_setup.*' -o -name '_local_setup_util_*.py' \) \
      -exec cp -a {} "${package_root}/opt/iros2j/" \;
    install -m 0644 "${repo_root}/packaging/iros2j.sh" \
      "${package_root}/etc/profile.d/iros2j.sh"
  fi

  python3 - "${package_root}/opt/iros2j" "${install_base}" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
old = sys.argv[2].encode()
new = b"/opt/iros2j"
for path in root.rglob("*"):
    if not path.is_file() or path.is_symlink():
        continue
    data = path.read_bytes()
    if old in data and not data.startswith(b"\x7fELF"):
        path.write_bytes(data.replace(old, new))
PY

  depends=()
  if [[ -n "${internal_depends}" ]]; then
    depends+=("${internal_depends}")
  fi
  external_depends=()
  for key in ${external_keys}; do
    if ! resolved_text="$(
      rosdep resolve \
        --rosdistro jazzy \
        --os=debian:trixie \
        "${key}"
    )"; then
      echo "Cannot resolve external runtime dependency ${key} for ${ros_name}." >&2
      exit 1
    fi
    mapfile -t resolved < <(
      printf '%s\n' "${resolved_text}" |
        sed -e '/^#/d' -e '/^[[:space:]]*$/d'
    )
    ((${#resolved[@]} > 0)) || {
      echo "rosdep returned no Debian package for ${key} (${ros_name})." >&2
      exit 1
    }
    external_depends+=("${resolved[@]}")
  done
  if ((${#external_depends[@]})); then
    mapfile -t external_depends < <(printf '%s\n' "${external_depends[@]}" | sort -u)
    depends+=("$(IFS=', '; echo "${external_depends[*]}")")
  fi
  depends_text="$(IFS=', '; echo "${depends[*]}")"

  {
    printf 'Package: %s\n' "${deb_name}"
    printf 'Version: %s\n' "${debian_version}"
    printf 'Section: robotics\n'
    printf 'Priority: optional\n'
    printf 'Architecture: %s\n' "${architecture}"
    printf 'Maintainer: Drone Age\n'
    if [[ -n "${depends_text}" ]]; then
      printf 'Depends: %s\n' "${depends_text}"
    fi
    printf 'Conflicts: iros2-0 (<< 1.0.0)\n'
    printf 'Replaces: iros2-0 (<< 1.0.0)\n'
    printf 'Description: iROS ROS 2 Jazzy package %s\n' "${ros_name}"
    printf ' Package %s from the iros2j Debian 13 distribution.\n' "${ros_name}"
  } > "${package_root}/DEBIAN/control"

  dpkg-deb --build --root-owner-group \
    "${package_root}" \
    "${output_dir}/${deb_name}_${debian_version}_${architecture}.deb"
done

python3 - "${manifest}" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
for package in data["packages"]:
    package.pop("prefix", None)
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

(
  cd "${output_dir}"
  sha256sum -- iros2j-*.deb | sort -k2 > SHA256SUMS
)

printf 'Created %s packages in %s\n' "${#package_rows[@]}" "${output_dir}"
