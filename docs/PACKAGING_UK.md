# Архітектура пакета IROS2_0

> **Legacy 0.1.x.** Цей документ описує опублікований монолітний пакет
> `iros2-0`. Цільову архітектуру `iros2j` v1 визначає
> [політика пакетів](PACKAGE_POLICY.uk.md).

Репозиторій містить build recipe, manifest, patches, package metadata, тести
та документацію. Upstream-код отримується через офіційний `ros2.repos`.

## Пакет

```text
Package: iros2-0
Architecture: amd64 або arm64
Install prefix: /opt/iros2_0/jazzy
```

Версія:

```text
<IROS2_VERSION>-<DEBIAN_REVISION>+deb13
```

Приклад: `0.1.0-1+deb13`.

## Залежність VINS-NEO

Після стабілізації:

```text
Depends: iros2-0 (>= 0.1.0-1+deb13)
```

Системні runtime dependencies повинні бути визначені через ELF dependency
scan. Поточний `control.in` є bootstrap-варіантом і не готовий до production,
доки список залежностей не перевірено.

## Критерії release

1. Upstream repositories зафіксовані commit SHA.
2. Base image зафіксований digest.
3. Усі patches збережені в Git.
4. Версії build dependencies записані.
5. Збережені build log, SHA-256 та SBOM.
6. Пакет завантажений з GitHub Release і встановлений на чистому Raspberry Pi.
7. `ros2` перевірений у новому login-shell.
8. RViz перевірений у новому GUI login-shell.
9. Пройдено SSH/offscreen smoke-test.

Повний acceptance-процес описаний у
[регламенті перевірки релізу](RELEASE_VERIFICATION_UK.md).

Версія `0.1.0` призначена для виявлення сумісності Jazzy з Debian 13 Trixie
AMD64 та ARM64 і не є production release.
