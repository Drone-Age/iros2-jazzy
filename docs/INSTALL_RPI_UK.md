# Встановлення IROS2_0 на Raspberry Pi 5

## Передумови

- Debian 13 Trixie ARM64;
- Raspberry Pi 5;
- SSH і `sudo`;
- `curl` та доступ до `github.com`;
- опублікований GitHub Release у `Drone-Age/iros2_0`.

```bash
uname -m
. /etc/os-release
printf '%s %s\n' "$ID" "$VERSION_CODENAME"
```

Очікується `aarch64` та `debian trixie`.

## Завантаження з GitHub Release

```bash
export IROS2_RELEASE_TAG=v0.1.0
export IROS2_PACKAGE_VERSION=0.1.0-1+deb13
base="https://github.com/Drone-Age/iros2_0/releases/download/${IROS2_RELEASE_TAG}"
asset="iros2-0_${IROS2_PACKAGE_VERSION}_arm64.deb"
curl -fLO "${base}/${asset}"
curl -fLO "${base}/SHA256SUMS"
```

## Встановлення

```bash
awk -v asset="${asset}" \
  '$2 == asset || $2 == "./" asset {print $1 "  " asset}' \
  SHA256SUMS | sha256sum -c -
sudo apt update
sudo apt install "./${asset}"
```

Використовуйте `apt install`, щоб APT встановив заявлені залежності.

## Перевірка

Закрийте поточний термінал. У новому терміналі перевірте `ros2`, а в іншому
новому терміналі запустіть `rviz2`. Повний ручний та автоматизований порядок:
[регламент перевірки релізу](RELEASE_VERIFICATION_UK.md).

## Видалення

```bash
sudo apt remove iros2-0
```
