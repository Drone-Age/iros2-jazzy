# IROS2_0

IROS2_0 — готовий пакет ROS 2 Jazzy для Debian 13 Trixie на AMD64 та для
Raspberry Pi 5 на ARM64. Після встановлення команди `ros2` і `rviz2` доступні у
звичайному терміналі без ручного налаштування середовища.

## Системні вимоги

- AMD64-комп'ютер або Raspberry Pi 5;
- Debian 13 Trixie AMD64 або ARM64;
- доступ до інтернету;
- команди `curl`, `sudo` та `apt`.

Перевірити систему:

```bash
uname -m
. /etc/os-release
printf '%s %s\n' "$ID" "$VERSION_CODENAME"
```

Очікуваний результат: архітектура `x86_64` або `aarch64` та система `debian trixie`.

## Швидке встановлення останнього релізу

Виконайте в терміналі:

```bash
mkdir -p /tmp/iros2-install
cd /tmp/iros2-install

arch="$(dpkg --print-architecture)"
curl -fLO "https://github.com/Drone-Age/iros2_0/releases/latest/download/iros2-0_latest_${arch}.deb"
curl -fLO "https://github.com/Drone-Age/iros2_0/releases/latest/download/iros2-0_latest_${arch}.deb.sha256"

sha256sum -c "iros2-0_latest_${arch}.deb.sha256"

sudo apt update
sudo apt install "./iros2-0_latest_${arch}.deb"
```

Під час встановлення APT автоматично додасть необхідні системні залежності.

## Перевірка

```bash
ros2 --help
rviz2
```

Для перевірки встановленої версії:

```bash
dpkg-query -W iros2-0
```

## Використання

Для звичайного запуску використовуйте `ros2` і `rviz2` без додаткових
команд:

```bash
ros2 topic list
rviz2
```

Для розробки, `colcon` workspace або ROS overlay активуйте повне середовище:

```bash
source /opt/iros2_0/jazzy/setup.bash
```

За бажанням можна один раз увімкнути автоматичну активацію для свого
Bash-користувача:

```bash
iros2-enable-bash
```

## Видалення

```bash
sudo apt purge iros2-0
sudo apt autoremove
```

Якщо раніше виконувалась команда `iros2-enable-bash`, видаліть із
`~/.bashrc` блок між рядками:

```text
# >>> iros2-0 >>>
# <<< iros2-0 <<<
```

## Релізи

Остання опублікована версія доступна на сторінці
[GitHub Releases](https://github.com/Drone-Age/iros2_0/releases/latest).
