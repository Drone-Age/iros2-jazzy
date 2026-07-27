# Versioning and tag policy

Product and release-process versions are independent.

## Product version

`VERSION` contains the three-component semantic version of the `iros2j`
package line:

```text
MAJOR.MINOR.PATCH
```

The package namespace already identifies the ROS generation: the `2` in
`iros2j` means ROS 2 and `j` means Jazzy. Therefore the first `iros2j` package
version is `1.0.0`, not `2.1.0.0`.

- `MAJOR`: incompatible package namespace, layout, API, or public behavior
  within that ROS generation.
- `MINOR`: backward-compatible package or functionality addition.
- `PATCH`: backward-compatible correction.

Git product tags add the ROS generation before the package version:

```text
v<ROS_GENERATION>.<MAJOR>.<MINOR>.<PATCH>
```

Consequently, `iros2j` package version `1.0.0` is published under Git tag
`v2.1.0.0`. The leading `2` belongs only to the repository tag and release
identity; it is not duplicated in the package version.

The Debian form is `<package-version>-<debian-revision>+deb13`, initially
`1.0.0-1+deb13`. A packaging-only rebuild may increment the Debian revision,
but any public replacement must receive a new immutable Git tag and release;
published assets are never overwritten.

All packages in one distribution snapshot use the same package version.
The upstream version of each ROS package is recorded separately in the
component manifest.

## Process version

`PROCESS_VERSION` is a three-component semantic version of regulations,
schemas, validators, build/publication scripts, issue forms, and release
automation. Its tags are `process-v<MAJOR>.<MINOR>.<PATCH>`.

- `MAJOR`: incompatible workflow, schema, support target, or gate change.
- `MINOR`: backward-compatible capability or mandatory extension.
- `PATCH`: compatible correction or clarification.

A process-only change does not change `VERSION`. A product-only change does
not change `PROCESS_VERSION`. If both change in one task, both new tags may
point to the same fully gated commit.

## Immutable tags

A tag is the output of a successful gate, never its input. Published product
and process tags must not be deleted, moved, or reused. A defect after tagging
requires a new version and a new tag.
