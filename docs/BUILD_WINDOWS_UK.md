# Ручна збірка IROS2_0 у Windows 11

Усі команди виконуються у PowerShell з кореня `iros2_0`.

## 1. Передумови

- Windows 11 x64;
- Git for Windows;
- Docker Desktop із WSL 2 backend;
- щонайменше 100 ГБ вільного місця;
- рекомендовано 16 ГБ RAM або більше;
- стабільне підключення до Інтернету.

Перша ARM64-збірка на x86-64 виконується через емуляцію і може тривати кілька
годин.

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

У platforms має бути `linux/arm64`.

Еквівалент:

```powershell
.\scripts\00-check-host.ps1
```

## 4. Build environment

```powershell
docker buildx build `
  --platform linux/arm64 `
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

Потім `vcs import` отримує upstream repositories.

```powershell
docker buildx build `
  --platform linux/arm64 `
  --target source `
  --progress plain `
  .
```

Поточний bootstrap використовує рухомий upstream manifest. Перед release
потрібно створити locked manifest із точними commit SHA.

## 6. Залежності Debian

```powershell
docker buildx build `
  --platform linux/arm64 `
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
  --platform linux/arm64 `
  --target build `
  --progress plain `
  .
```

Install prefix: `/opt/iros2_0/jazzy`. Збірка: `Release`, `BUILD_TESTING=OFF`,
`--merge-install`, `--executor sequential`.

## 8. DEB-пакет

```powershell
$Version = (Get-Content VERSION -Raw).Trim()
$BuildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$VcsRef = (git rev-parse HEAD).Trim()

docker buildx build `
  --platform linux/arm64 `
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
├── iros2-0_0.1.0-1+deb13_arm64.deb
└── SHA256SUMS
```

## 9. Перевірка

```powershell
.\scripts\30-verify-package.ps1
```

Перевіряються checksum, інсталяція через APT у чистому Debian Trixie ARM64 та
запуск ROS CLI.

## 10. Публікація

У GitHub Release публікуються `.deb`, `SHA256SUMS`, locked manifest, build log,
відомі обмеження і результати тестів. `.deb` не додається до Git.
