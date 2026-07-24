#!/usr/bin/env bash
set -Eeuo pipefail

package_version="${IROS2_VERSION}-1+deb13"
package_root="/tmp/iros2-jazzy_${package_version}_arm64"

mkdir -p \
  "${package_root}/DEBIAN" \
  "${package_root}/opt/iros2" \
  "${package_root}/etc/profile.d" \
  /out

cp -a /opt/iros2/jazzy "${package_root}/opt/iros2/jazzy"
install -m 0644 /work/packaging/iros2-jazzy.sh \
  "${package_root}/etc/profile.d/iros2-jazzy.sh"

sed \
  -e "s/@VERSION@/${package_version}/g" \
  -e "s/@BUILD_DATE@/${BUILD_DATE}/g" \
  -e "s/@VCS_REF@/${VCS_REF}/g" \
  /work/packaging/control.in > "${package_root}/DEBIAN/control"

installed_size="$(du -sk "${package_root}" | cut -f1)"
printf 'Installed-Size: %s\n' "${installed_size}" \
  >> "${package_root}/DEBIAN/control"

dpkg-deb --build --root-owner-group \
  "${package_root}" \
  "/out/iros2-jazzy_${package_version}_arm64.deb"

cd /out
sha256sum ./*.deb > SHA256SUMS
