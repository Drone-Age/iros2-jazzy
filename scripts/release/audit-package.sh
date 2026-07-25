#!/usr/bin/env bash
set -Eeuo pipefail

deb="${1:?Usage: audit-package.sh PACKAGE.deb [INSTALLED_PREFIX]}"
prefix="${2:-/opt/iros2_0/jazzy}"
extract_dir="$(mktemp -d)"
dependency_paths="$(mktemp)"
contents_file="$(mktemp)"
trap 'rm -rf -- "${extract_dir}" "${dependency_paths}" "${contents_file}"' EXIT

dpkg-deb --info "${deb}" >/dev/null
dpkg-deb --contents "${deb}" > "${contents_file}"
grep -q './opt/iros2_0/jazzy/setup.bash' "${contents_file}"
grep -q './opt/iros2_0/jazzy/rviz2/bin/rviz2' "${contents_file}"

dpkg-deb --extract "${deb}" "${extract_dir}"

if grep -R -I -l -m 1 \
  -e '/home/rpi/iros2_0-native' \
  -e '/work/build' \
  -e '/work/src' \
  -e '/work/install' \
  "${extract_dir}/opt/iros2_0/jazzy"; then
  echo "Non-portable build path found in package payload." >&2
  exit 1
fi

while IFS= read -r -d '' link; do
  target="$(readlink "${link}")"
  if [[ "${target}" == /home/* || "${target}" == /work/* ]]; then
    echo "Non-portable symlink: ${link} -> ${target}" >&2
    exit 1
  fi
done < <(find "${extract_dir}" -type l -print0)

while IFS= read -r -d '' candidate; do
  if ! readelf -h "${candidate}" >/dev/null 2>&1; then
    continue
  fi
  if readelf -d "${candidate}" 2>/dev/null |
     grep -E 'RPATH|RUNPATH' |
     grep -E '/home/|/work/'; then
    echo "Non-portable ELF RPATH/RUNPATH: ${candidate}" >&2
    exit 1
  fi
done < <(find "${extract_dir}" -type f -print0)

test -f "${prefix}/setup.bash"
set +u
source "${prefix}/setup.bash"
set -u

while IFS= read -r -d '' candidate; do
  if ! readelf -h "${candidate}" >/dev/null 2>&1; then
    continue
  fi
  ldd "${candidate}" 2>/dev/null |
    awk '/=> not found/ {print "MISSING:" $1}
         /=> \// {print $3}
         /^\// {print $1}' >> "${dependency_paths}" || true
done < <(find "${prefix}" -type f -print0)

missing_external=0
while IFS= read -r missing_library; do
  missing_library="${missing_library#MISSING:}"
  if find "${prefix}" -type f -name "${missing_library}" -print -quit |
     grep -q .; then
    echo "Internally packaged plugin dependency: ${missing_library}"
  else
    echo "Missing external ELF dependency: ${missing_library}" >&2
    missing_external=1
  fi
done < <(grep '^MISSING:' "${dependency_paths}" | sort -u || true)
(( missing_external == 0 ))

echo "External ELF runtime packages:"
while IFS= read -r library; do
  real_library="$(readlink -f "${library}")"
  owner="$(dpkg-query -S "${real_library}" 2>/dev/null | head -n 1 || true)"
  [[ -n "${owner}" ]] || continue
  owner="${owner%%: /*}"
  owner="${owner%:arm64}"
  printf '%s\n' "${owner}"
done < <(grep '^/' "${dependency_paths}" | sort -u) | sort -u

echo "Package portability and ELF dependency audit PASSED."
