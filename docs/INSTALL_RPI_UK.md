# Встановлення IROS2_0 на Raspberry Pi 5

## Передумови

- Debian 13 Trixie ARM64;
- Raspberry Pi 5;
- SSH і `sudo`;
- готовий `iros2-0_*_arm64.deb`.

```bash
uname -m
. /etc/os-release
printf '%s %s\n' "$ID" "$VERSION_CODENAME"
```

Очікується `aarch64` та `debian trixie`.

## Передавання

```powershell
scp artifacts\iros2-0_0.1.0-1+deb13_arm64.deb rpi@<IP>:/tmp/
scp artifacts\SHA256SUMS rpi@<IP>:/tmp/
```

## Встановлення

```bash
cd /tmp
sha256sum -c SHA256SUMS
sudo apt update
sudo apt install ./iros2-0_0.1.0-1+deb13_arm64.deb
```

Використовуйте `apt install`, щоб APT встановив заявлені залежності.

## Перевірка

```bash
source /opt/iros2_0/jazzy/setup.bash
echo "$ROS_DISTRO"
ros2 --help
ros2 doctor --report
```

## Видалення

```bash
sudo apt remove iros2-0
```
