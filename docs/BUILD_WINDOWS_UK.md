# Ручна збірка IROS2_0 у Windows 11

> **Legacy 0.1.x.** Docker/Buildx та AMD64 не входять до цільового процесу
> `iros2j` v1. Цей документ не можна використовувати для `v2.1.0.0`; див.
> [план міграції](V1_MIGRATION_PLAN.uk.md).

Усі команди виконуються у PowerShell з кореня `iros2_0`.

## 1. Передумови

- Windows 11 x64;
- Git for Windows;
- Docker Desktop із WSL 2 backend;
- щонайменше 100 ГБ вільного місця;
- рекомендовано 16 ГБ RAM або більше;
- стабільне підключення до Інтернету.

AMD64 збирається першою та нативно для Windows x64 host. Після неї ARM64-збірка
виконується через емуляцію і може тривати кілька годин.

## 2. Отримання репозиторію

```powershell
git clone https://github.com/Drone-Age/iros2_0.git
Set-Location iros2_0
git status
```

Для release використовуйте конкретний Git-тег:

```powershell
git fetch --tags
git checkout <RELEASE-TAG>
```

## 3. Перевірка Docker

```powershell
docker version
docker buildx version
docker buildx inspect --bootstrap
```

У platforms мають бути `linux/amd64` та `linux/arm64`.

Еквівалент:

```powershell
.\scripts\00-check-host.ps1
```

## 4. Build environment

```powershell
docker buildx build `
  --platform linux/amd64 `
  --target environment `
  --tag iros2-0:build-environment `
  --load `
  .
```

Або:

```powershell
.\scripts\10-build-environment.ps1
```

## 5. Вихідний код

Dockerfile завантажує офіційний Jazzy manifest:

```text
https://raw.githubusercontent.com/ros2/ros2/jazzy/ros2.repos
```

Потім `vcs import` отримує upstream repositories, а офіційний
`ros2/variants` гілки Jazzy додає метапакет `ros_base`.

```powershell
docker buildx build `
  --platform linux/amd64 `
  --target source `
  --progress plain `
  .
```

Поточний bootstrap використовує рухомий upstream manifest. Перед release
потрібно створити locked manifest із точними commit SHA.

## 6. Залежності Debian

```powershell
docker buildx build `
  --platform linux/amd64 `
  --target dependencies `
  --progress plain `
  .
```

`rosdep` працює з `--rosdistro jazzy --os=debian:trixie`. Якщо залежність
відсутня, build має завершитися помилкою. Ubuntu repositories підключати до
Debian не можна.

## 7. Компіляція

```powershell
docker buildx build `
  --platform linux/amd64 `
  --target build `
  --progress plain `
  .
```

Install prefix: `/opt/iros2_0/jazzy`. Профіль: `ros_base + rviz2`, без Gazebo
Simulator. Збірка: `Release`, `BUILD_TESTING=OFF`, isolated install,
`--executor sequential`.

## 8. DEB-пакет

```powershell
$Version = (Get-Content VERSION -Raw).Trim()
$BuildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$VcsRef = (git rev-parse HEAD).Trim()

docker buildx build `
  --platform linux/amd64 `
  --target artifact `
  --build-arg "IROS2_VERSION=$Version" `
  --build-arg "BUILD_DATE=$BuildDate" `
  --build-arg "VCS_REF=$VcsRef" `
  --output "type=local,dest=artifacts" `
  --progress plain `
  .
```

Або:

```powershell
.\scripts\20-build-package.ps1
```

Результат:

```text
artifacts/
├── iros2-0_0.1.0-1+deb13_amd64.deb
├── iros2-0_latest_amd64.deb
├── iros2-0_0.1.0-1+deb13_arm64.deb
├── iros2-0_latest_arm64.deb
└── SHA256SUMS
```

Скрипт завжди створює release-артефакти у фіксованому порядку: спочатку AMD64,
потім ARM64.

## 9. Перевірка

Release-перевірки не виконуються в Docker. Після публікації GitHub Release
запустіть native acceptance cycle на Raspberry Pi безпосередньо або через
SSH:

```powershell
.\scripts\release\verify-via-ssh.ps1
```

Див. [регламент перевірки релізу](RELEASE_VERIFICATION_UK.md).

## 10. Публікація

У GitHub Release публікуються `.deb`, `SHA256SUMS`, locked manifest, build log,
відомі обмеження і результати тестів. `.deb` не додається до Git.
