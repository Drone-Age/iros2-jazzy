# Release-процес `iros2j`

Це обов'язковий процес для продуктових релізів v1. Незмінний baseline
`v2.1.0.0` уже існує; перша повна реалізація пакетів має пройти цей процес як
версія пакетів `1.0.1` і тег `v2.1.0.1`.

## 1. Відкрити й зафіксувати release

Створіть Release issue. Запишіть версію продукту, запропонований незмінний
тег, `PROCESS_VERSION`, scope, source commit, ідентичність Debian 13 ARM64
builder та відомі ризики. Створіть версійний component manifest, який фіксує
commit кожного upstream repository, upstream-версію пакета, вирішені зовнішні
залежності, версії toolchain, конфігурацію збірки й очікуваний набір пакетів.

Одночасно оновіть і додайте до Git index:

- `VERSION`;
- версійний component/release manifest;
- `CHANGELOG.md`;
- версійні release notes;
- вхідні дані metadata індексу пакетів.

## 2. Перевірити закомічений snapshot

Metadata validation спочатку виконується для staged Git index, а потім для
створеного коміту. Вона має відхиляти release-дані лише у working tree,
незафіксовані sources, порушення перетворення імен пакетів, залежності від
legacy-пакетів, розбіжності версій, відсутню двомовну документацію та неповний
набір пакетів.

Продуктовий тег на цьому етапі не створюється.

## 3. Нативний gate Debian 13 ARM64

Зберіть точний pushed commit на нативному хості Debian 13 Trixie `aarch64`.
Зафіксуйте host identity, OS, kernel, compiler, glibc, Python, CMake, colcon,
вирішені залежності, source commits, timestamps і повні logs.

Gate має:

1. зібрати кожен пакет і метапакет у порядку залежностей;
2. виконати доступні unit та integration tests;
3. перевірити імена, версії, архітектури, залежності, ownership, install
   prefix та відсутність build-host paths;
4. виконати `ldd` для кожного ELF і відхилити всі невирішені libraries;
5. створити й перевірити підписані metadata APT repository;
6. установити вибраний метапакет із цього repository на чисту систему Debian
   13 ARM64;
7. перевірити ROS discovery та репрезентативні runtime smoke tests у чистому
   shell;
8. налаштувати, зібрати й запустити чистий downstream CMake consumer, який
   знаходить кожну source-owned non-ament development-залежність, потрібну
   експортованим metadata ROS-пакетів;
9. перевірити uninstall/upgrade із legacy 0.1.x там, де це застосовно;
10. створити checksums, SBOM, package/component manifest та fail-closed
   версійний evidence.

Збірка, встановлення та smoke-test VINS-NEO явно не входять до gate цього
репозиторію. Перевірки AMD64, Docker і QEMU не можна додавати до release
послідовності v1.

Після успішного native run фіналізуйте draft manifest, додавши artifact hashes
і точний build commit:

```bash
python3 scripts/release/finalize-release.py \
  --manifest manifests/iros2j-<version>.json \
  --artifacts artifacts \
  --build-commit <native-build-commit>
```

Закомітьте й push фінальний metadata snapshot. На тому самому нативному ARM64
host створіть `native-gate.json` для фінального release commit за допомогою
`create-native-gate.py`. Build commit і release commit записуються окремо; між
ними можуть відрізнятися лише release metadata.

## 4. Публікація

Інструмент публікації має прив'язувати успішний native evidence до точного
source commit, manifest hash, snapshot APT repository та artifact hashes. Він
має відхиляти вже наявний тег або release.

Лише після проходження всіх gate дозволено створити на цьому коміті
кваліфікований поколінням продуктовий тег за правилами `VERSIONING.md` (для
версії пакета `1.0.1` — `v2.1.0.1`) та завантажити APT
bootstrap/repository bundle, checksums, manifests, SBOM, logs/evidence і
закомічені release notes. Тег і release assets незмінні.

## 5. Перевірка після публікації

На чистому підтримуваному ARM64 host перевірте, що опублікований тег вказує на
gated commit, завантажте metadata repository, перевірте signatures і
checksums, установіть пакети через APT та повторіть runtime smoke-test у
чистому shell. Запишіть результат у Release issue до його закриття.

Якщо дефект знайдено після створення тегу, позначте release дефектним і
опублікуйте новий PATCH після повного повторення gate. Старий тег ніколи не
пересувається й не використовується повторно.
