# Документація

Цей індекс визначає нормативне джерело вимог для переходу на `iros2j` v1 та
release-процесу. Англійська версія є канонічною, а українські файли —
обов'язковими підтримуваними перекладами.

## Нормативні документи

- [Політика документації](DOCUMENTATION_POLICY.md) /
  [українською](DOCUMENTATION_POLICY.uk.md)
- [Версії та теги](VERSIONING.md) /
  [українською](VERSIONING.uk.md)
- [Політика пакетів](PACKAGE_POLICY.md) /
  [українською](PACKAGE_POLICY.uk.md)
- [Release-процес](RELEASE_PROCESS.md) /
  [українською](RELEASE_PROCESS.uk.md)
- [План переходу v1](V1_MIGRATION_PLAN.md) /
  [українською](V1_MIGRATION_PLAN.uk.md)

Legacy-інструкції 0.1.x для Docker, AMD64, монолітного пакування, встановлення
та перевірки видалено після початку реалізації `iros2j`. Опубліковані теги
зберігають історичні sources.

## Модель процесу

Структуру процесу адаптовано з
[`Drone-Age/iMAVROS-release`](https://github.com/Drone-Age/iMAVROS-release):
незалежні версії продукту/процесу, незмінні продуктові та `process-v*` теги,
двомовні нормативні пари, release issues, pinned manifests, native evidence,
прив'язаний до коміту, і створення тегів лише після успішних gate.
Специфічні для iMAVROS вимоги, наприклад FCU hardware testing, не копіювалися.
