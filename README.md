# IROS2_0

Відтворювана збірка ROS 2 Jazzy для Raspberry Pi 5 з Debian 13 Trixie.

| Параметр | Значення |
|---|---|
| Build host | Windows 11 + Docker Desktop |
| Build container | Debian 13 Trixie |
| Target | Raspberry Pi 5, ARM64 (`aarch64`) |
| ROS distribution | Jazzy |
| Артефакт | `iros2-0_<version>_arm64.deb` |

> ROS 2 Jazzy офіційно постачається для Ubuntu 24.04. Збірка для Debian 13 є
> власним портом INDRA і повинна пройти повний compatibility та runtime test
> перед використанням на кінцевому обладнанні.

## Документація

- [Повна ручна збірка у Windows 11](docs/BUILD_WINDOWS_UK.md)
- [Встановлення на Raspberry Pi](docs/INSTALL_RPI_UK.md)
- [Регламент перевірки релізу](docs/RELEASE_VERIFICATION_UK.md)
- [Архітектура пакета і release-процес](docs/PACKAGING_UK.md)

## Швидкий початок

У PowerShell:

```powershell
.\scripts\00-check-host.ps1
.\scripts\10-build-environment.ps1
.\scripts\20-build-package.ps1
.\scripts\30-verify-package.ps1
```

Результати створюються в `artifacts/` і не зберігаються в Git.
