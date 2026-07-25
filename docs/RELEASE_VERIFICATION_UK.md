# Регламент перевірки релізу IROS2_0

## Критерій успішного релізу

Реліз вважається прийнятим лише після повного циклу на Raspberry Pi 5 з
Debian 13 Trixie ARM64:

1. `.deb` і `SHA256SUMS` завантажені саме з GitHub Release.
2. SHA-256 збігається.
3. Попередній пакет видалений, а `/opt/iros2_0/jazzy` не містить залишків
   ручної збірки.
4. Пакет встановлений командою `apt install`.
5. У новому login-shell доступний `ros2`, `ROS_DISTRO=jazzy`, присутній
   `ros_base`, а `ros2 doctor` завершується успішно.
6. В іншому новому login-shell RViz запускається з GUI і залишається
   працездатним щонайменше 10 секунд.

SSH/offscreen-перевірка є обов'язковим автоматизованим smoke-test, але не
замінює локальний GUI-тест. Підсумковий статус `release accepted` дозволений
тільки після локального GUI-тесту.

## Ручна перевірка

Задайте версію релізу:

```bash
export IROS2_RELEASE_TAG=v0.1.0
export IROS2_PACKAGE_VERSION=0.1.0-1+deb13
export IROS2_GITHUB_REPO=Drone-Age/iros2_0
```

Завантажте артефакти:

```bash
mkdir -p ~/iros2-release-test
cd ~/iros2-release-test
base="https://github.com/${IROS2_GITHUB_REPO}/releases/download/${IROS2_RELEASE_TAG}"
asset="iros2-0_${IROS2_PACKAGE_VERSION}_arm64.deb"
curl -fLO "${base}/${asset}"
curl -fLO "${base}/SHA256SUMS"
grep -F " ${asset}" SHA256SUMS | sha256sum -c -
```

На чистій тестовій системі встановіть пакет:

```bash
sudo apt purge -y iros2-0 || true
test ! -e /opt/iros2_0/jazzy
sudo apt update
sudo apt install "./${asset}"
dpkg-query -W iros2-0
```

Закрийте термінал, відкрийте новий і виконайте:

```bash
test "$ROS_DISTRO" = jazzy
command -v ros2
ros2 --help
ros2 pkg prefix ros_base
ros2 doctor --report
```

Закрийте його, відкрийте ще один новий термінал у графічній сесії Pi:

```bash
command -v rviz2
rviz2
```

Критерій: вікно RViz відкривається, не завершується з помилкою Qt/OpenGL,
відображає стандартну сцену та реагує на керування.

## Автоматична native-перевірка

Скрипт виконує завантаження, checksum, чисте встановлення та два незалежні
login-shell тести:

```bash
cd iros2_0
export IROS2_RELEASE_TAG=v0.1.0
export IROS2_PACKAGE_VERSION=0.1.0-1+deb13
export IROS2_RVIZ_MODE=gui
./scripts/release/verify-native.sh
```

Якщо на build-машині залишився ручний `/opt/iros2_0/jazzy`, скрипт безпечно
зупиниться. Видалення дозволяється лише явно:

```bash
export IROS2_ALLOW_REMOVE_PREFIX=1
```

Цю змінну не слід використовувати на системі з важливими незапакованими
даними.

## Перевірка через SSH

Запускайте у PowerShell на Windows 11. Параметри підключення передаються
виключно змінними середовища:

```powershell
$env:IROS2_SSH_HOST = "192.168.144.109"
$env:IROS2_SSH_USER = "rpi"
$env:IROS2_SSH_PORT = "22"
$env:IROS2_SSH_KEY = "$env:USERPROFILE\.ssh\id_ed25519"
$env:IROS2_RELEASE_TAG = "v0.1.0"
$env:IROS2_PACKAGE_VERSION = "0.1.0-1+deb13"
$env:IROS2_GITHUB_REPO = "Drone-Age/iros2_0"

.\scripts\release\verify-via-ssh.ps1
```

SSH-скрипт копіює native-verifier на Pi та запускає його у режимі
`IROS2_RVIZ_MODE=offscreen`. Усі перевірки виконуються на нативній системі;
Windows лише керує SSH-сеансом.

## Протокол результатів

До GitHub Release додаються:

- `iros2-0_<version>_arm64.deb`;
- `SHA256SUMS`;
- build log;
- протокол native GUI-перевірки;
- протокол SSH/offscreen-перевірки;
- commit SHA джерел збірки.

У разі помилки реліз не змінюється «на місці». Виправлення отримує новий
Debian revision або новий release tag, після чого весь цикл повторюється.

