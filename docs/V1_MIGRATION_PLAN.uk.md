# План переходу на `iros2j` v1

Цей контрольний список визначає готовність до `v2.1.0.0`. Позначені виконаними
пункти мають підтверджуватися закоміченим кодом, тестами або release evidence.

## Пакування

- [ ] Створювати один Debian-пакет на кожен ROS-пакет за детермінованим
      перетворенням `iros2j-*`.
- [ ] Створювати точні внутрішні залежності та метапакети в офіційному стилі.
- [ ] Установлювати повний дистрибутив у `/opt/iros2j`.
- [ ] Видалити всі визначення legacy-монолітів та належний їм payload.
- [ ] Визначити й перевірити явний чистий перехід зі встановленої версії 0.1.x.
- [ ] Створювати підписаний snapshot APT repository та bootstrap installer.

## Scope збірки

- [ ] Видалити Dockerfiles, Docker entrypoints, container helpers, Buildx
      scripts і документацію Docker-збірки.
- [ ] Видалити шляхи збірки, публікації, перевірки та підтримки AMD64.
- [ ] Залишити нативний Debian 13 Trixie ARM64 єдиним шляхом бінарного релізу.
- [ ] Переконатися, що цей репозиторій не містить перевірки VINS-NEO.

## Metadata та gate

- [ ] Додати версійний component/release manifest і машинну схему.
- [ ] Зафіксувати upstream commits, upstream package versions, залежності,
      toolchain, package set, архітектуру та install prefix.
- [ ] Додати metadata validators для staged index і committed snapshot.
- [ ] Додати gate для naming, dependencies, ownership, ELF, clean install,
      APT, checksums, SBOM та evidence.
- [ ] Додати відновлювану нативну збірку з незмінним run identity та
      fail-closed status.
- [ ] Додати publisher, який створює тег лише після успішного evidence і
      відхиляє наявні теги/releases.

## Документація та release

- [ ] Замінити legacy-інструкції користувача на APT workflow.
- [ ] Додати версійні release notes `v2.1.0.0` і фінальний package inventory.
- [ ] Установити `VERSION` у `1.0.0` лише в реальній зміні підготовки release;
      використати repository tag `v2.1.0.0`.
- [ ] Пройти повний native gate на точному pushed release commit.
- [ ] Опублікувати незмінний `v2.1.0.0` і завершити post-release verification на
      чистому host.
