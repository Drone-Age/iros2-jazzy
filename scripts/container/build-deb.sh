#!/usr/bin/env bash
set -Eeuo pipefail

install_prefix="${IROS2_INSTALL_PREFIX:-/opt/iros2_0/jazzy}"
output_dir="${IROS2_OUTPUT_DIR:-/out}"
packaging_dir="${IROS2_PACKAGING_DIR:-/work/packaging}"
package_arch="${IROS2_ARCH:-$(dpkg --print-architecture)}"
package_version="${IROS2_VERSION:?IROS2_VERSION is required}-1+deb13"
package_root="$(mktemp -d "/tmp/iros2-0_${package_version}_${package_arch}.XXXXXX")"
trap 'rm -rf -- "${package_root}"' EXIT

if [[ "${package_arch}" != "arm64" ]]; then
  echo "IROS2_0 package must be built on/for arm64, got: ${package_arch}" >&2
  exit 1
fi
test -f "${install_prefix}/setup.bash"

mkdir -p \
  "${package_root}/DEBIAN" \
  "${package_root}/opt/iros2_0" \
  "${package_root}/etc/profile.d" \
  "${output_dir}"

cp -a "${install_prefix}" "${package_root}/opt/iros2_0/jazzy"
install -m 0644 "${packaging_dir}/iros2-0.sh" \
  "${package_root}/etc/profile.d/iros2-0.sh"

# google_benchmark_vendor 1.8.3 generates a pkg-config file with its temporary
# ExternalProject install prefix. Normalize it to the final package prefix for
# both native and Docker builds.
benchmark_pc="${package_root}/opt/iros2_0/jazzy/google_benchmark_vendor/lib/pkgconfig/benchmark.pc"
if [[ -f "${benchmark_pc}" ]]; then
  sed -i \
    -e 's|^prefix=.*|prefix=/opt/iros2_0/jazzy/google_benchmark_vendor|' \
    -e 's|^exec_prefix=.*|exec_prefix=${prefix}|' \
    -e 's|^libdir=.*|libdir=${prefix}/lib|' \
    -e 's|^includedir=.*|includedir=${prefix}/include|' \
    "${benchmark_pc}"
fi

runtime_depends="$(
  grep -Ev '^[[:space:]]*(#|$)' "${packaging_dir}/runtime-depends.txt" |
    sort -u |
    paste -sd, - |
    sed 's/,/, /g'
)"
test -n "${runtime_depends}"

sed \
  -e "s/@VERSION@/${package_version}/g" \
  -e "s/@BUILD_DATE@/${BUILD_DATE}/g" \
  -e "s/@VCS_REF@/${VCS_REF}/g" \
  -e "s/@DEPENDS@/${runtime_depends}/g" \
  "${packaging_dir}/control.in" > "${package_root}/DEBIAN/control"

installed_size="$(du -sk "${package_root}" | cut -f1)"
printf 'Installed-Size: %s\n' "${installed_size}" \
  >> "${package_root}/DEBIAN/control"

dpkg-deb --build --root-owner-group \
  "${package_root}" \
  "${output_dir}/iros2-0_${package_version}_${package_arch}.deb"

cd "${output_dir}"
sha256sum ./*.deb > SHA256SUMS
