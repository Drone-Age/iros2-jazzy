# `iros2j` package policy

This policy defines the accepted v1 target. It does not claim that the current
0.1.x implementation already satisfies it.

## Identity and platform

- Debian package namespace: `iros2j`.
- Internal ROS distribution: `jazzy`; keep `ROS_DISTRO=jazzy`.
- Shared install prefix: `/opt/iros2j`.
- Supported binary platform: Debian 13 Trixie ARM64 (`arm64`/`aarch64`).
- Architecture-independent packages may use `Architecture: all`.
- AMD64 is not built, tested, documented, or supported.
- Regular releases are built natively; Docker and QEMU are not release paths.

## One ROS package, one Debian package

Each ROS package is shipped in a separate Debian package with official
ROS-style content ownership: runtime libraries/executables, headers, resource
index entries, interfaces, Python modules, and CMake/package metadata belong
to that package. A single global development package is forbidden.

The deterministic name mapping is:

```text
ros-jazzy-<normalized-name>  ->  iros2j-<normalized-name>
```

ROS package underscores are normalized to Debian hyphens. `jazzy` is omitted
from the custom package name. Examples:

| ROS / official package | `iros2j` Debian package |
|---|---|
| `ros_core` / `ros-jazzy-ros-core` | `iros2j-ros-core` |
| `rclcpp` / `ros-jazzy-rclcpp` | `iros2j-rclcpp` |
| `sensor_msgs` / `ros-jazzy-sensor-msgs` | `iros2j-sensor-msgs` |
| `cv_bridge` / `ros-jazzy-cv-bridge` | `iros2j-cv-bridge` |
| `rviz2` / `ros-jazzy-rviz2` | `iros2j-rviz2` |

ROS dependency `<depend>rclcpp</depend>` maps to an exact snapshot dependency,
for example `iros2j-rclcpp (= 1.0.1-1+deb13)`.

Plain-CMake projects present in the exact ROS source lock and required by ROS
packages are also snapshot-owned packages even when they do not install a
`package.xml`. In particular, the pinned `fastcdr` and `fastrtps` install
prefixes must be packaged as `iros2j-fastcdr` and `iros2j-fastrtps`.
`rmw_fastrtps_*` must depend on those exact snapshot packages; it must not
substitute a distribution Fast DDS major version with incompatible CMake
metadata.

## Metapackages

The initial metapackage set is:

- `iros2j-ros-core`
- `iros2j-ros-base`
- `iros2j-common-interfaces`
- `iros2j-vision-opencv`
- `iros2j-rviz2`

`iros2j-desktop` may be added only when its dependency closure matches the
corresponding official ROS variant. Metapackages contain dependency metadata,
not copied payload from their member packages.

## Forbidden legacy and false compatibility

The monolithic packages `iros2-0`, `iros2-core`, `iros2-interfaces`,
`iros2-vision`, `iros2-rviz`, and `iros2-development` are removed from v1.
They must not be recreated under the `iros2j` namespace.

Do not declare `Provides: ros-jazzy-*` while paths, ownership, and
compatibility differ from official packages. Migration from 0.1.x must use an
explicit remove/conflict transition and clean installation validation.

## Repository distribution

The supported delivery mechanism is a signed APT repository with `Packages`,
`Release`, and checksum metadata. A GitHub Release contains a repository or
bootstrap bundle, `SHA256SUMS`, component/source manifest, SBOM, release notes,
and gate evidence. It must not publish hundreds of unrelated flat `.deb`
assets.
