#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
artifacts="${IROS2_OUTPUT_DIR:-${repo_root}/artifacts}"
repository="${IROS2_APT_REPOSITORY:-${artifacts}/apt-repository}"
suite="${IROS2_APT_SUITE:-trixie}"
component="${IROS2_APT_COMPONENT:-main}"
origin="${IROS2_APT_ORIGIN:-Drone Age}"
label="${IROS2_APT_LABEL:-iros2j}"
gpg_key="${IROS2_GPG_KEY:?IROS2_GPG_KEY is required for signed APT metadata}"

command -v dpkg-scanpackages >/dev/null
command -v apt-ftparchive >/dev/null
command -v gpg >/dev/null

artifacts="$(realpath -m "${artifacts}")"
repository="$(realpath -m "${repository}")"
case "${repository}" in
  "${artifacts}"/*) ;;
  *)
    echo "Refusing to replace APT repository outside ${artifacts}: ${repository}" >&2
    exit 1
    ;;
esac
rm -rf -- "${repository}"
pool="${repository}/pool/${component}/i/iros2j"
binary="${repository}/dists/${suite}/${component}/binary-arm64"
mkdir -p "${pool}" "${binary}"

shopt -s nullglob
packages=("${artifacts}"/iros2j-*.deb)
((${#packages[@]} > 0))
cp -a -- "${packages[@]}" "${pool}/"

(
  cd "${repository}"
  dpkg-scanpackages --arch arm64 "pool/${component}" /dev/null \
    > "dists/${suite}/${component}/binary-arm64/Packages"
  gzip -n -9 -c "dists/${suite}/${component}/binary-arm64/Packages" \
    > "dists/${suite}/${component}/binary-arm64/Packages.gz"

  apt-ftparchive \
    -o "APT::FTPArchive::Release::Origin=${origin}" \
    -o "APT::FTPArchive::Release::Label=${label}" \
    -o "APT::FTPArchive::Release::Suite=${suite}" \
    -o "APT::FTPArchive::Release::Codename=${suite}" \
    -o "APT::FTPArchive::Release::Architectures=arm64" \
    -o "APT::FTPArchive::Release::Components=${component}" \
    release "dists/${suite}" > "dists/${suite}/Release"

  gpg --batch --yes --local-user "${gpg_key}" \
    --armor --detach-sign \
    --output "dists/${suite}/Release.gpg" \
    "dists/${suite}/Release"
  gpg --batch --yes --local-user "${gpg_key}" \
    --armor --clearsign \
    --output "dists/${suite}/InRelease" \
    "dists/${suite}/Release"
  gpg --batch --yes --local-user "${gpg_key}" \
    --armor --export "${gpg_key}" > iros2j-archive-keyring.asc
)

archive="${artifacts}/iros2j-apt_${suite}_arm64.tar.gz"
tar --sort=name --mtime="@${SOURCE_DATE_EPOCH:-0}" \
  --owner=0 --group=0 --numeric-owner \
  -C "${artifacts}" -czf "${archive}" apt-repository
sha256sum -- "${archive}" > "${archive}.sha256"
printf 'Created signed APT repository: %s\n' "${archive}"
