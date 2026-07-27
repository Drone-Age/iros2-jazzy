# iros2j

`iros2j` — пакетна збірка ROS 2 Jazzy для Debian 13 Trixie ARM64. Кожен
ROS-пакет постачається окремим Debian-пакетом `iros2j-*`, а встановлення
виконується через підписаний APT repository.

## Стан

Поточна розроблювана версія пакетів: `1.0.1`.

Запланований Git release tag: `v2.1.0.1`, де перша `2` позначає ROS 2, а
`1.0.1` є версією пакетної лінії `iros2j`.

Підтримується лише нативний Debian 13 Trixie ARM64 (`aarch64`). Docker,
AMD64, QEMU та перевірка VINS-NEO не входять до цього проєкту.

## Пакетна модель

Ім'я офіційного пакета перетворюється детерміновано:

```text
ros-jazzy-<package>  ->  iros2j-<package>
```

Приклади: `iros2j-rclcpp`, `iros2j-sensor-msgs`, `iros2j-cv-bridge`,
`iros2j-ros-core`, `iros2j-ros-base` та `iros2j-rviz2`.

Усі файли встановлюються під спільний prefix `/opt/iros2j`. Внутрішні
залежності пакетів фіксуються на точну версію одного snapshot.

## Нативна збірка

На чистому ARM64 host Debian 13:

```bash
git clone https://github.com/Drone-Age/iros2_0.git
cd iros2_0

IROS2_INSTALL_DEPENDENCIES=1 \
IROS2_GPG_KEY=<release-key-id> \
  ./scripts/native/release-rpi.sh
```

Скрипт використовує exact source lock, збирає isolated ROS prefixes, створює
окремі `.deb`, перевіряє package metadata, формує підписаний APT repository та
SPDX SBOM.

## Перевірка локального repository bundle

```bash
./scripts/release/verify-native.sh \
  artifacts/iros2j-apt_trixie_arm64.tar.gz
```

Перевірка виконує APT-встановлення метапакетів і ROS/RViz smoke tests у чистому
shell. Для release необхідний повний native gate за
[регламентом](docs/RELEASE_PROCESS.uk.md).

## Документація

- [Індекс нормативної документації](docs/README.uk.md)
- [Політика пакетів](docs/PACKAGE_POLICY.uk.md)
- [Release-процес](docs/RELEASE_PROCESS.uk.md)
- [План міграції](docs/V1_MIGRATION_PLAN.uk.md)
- [Версії та теги](docs/VERSIONING.uk.md)
