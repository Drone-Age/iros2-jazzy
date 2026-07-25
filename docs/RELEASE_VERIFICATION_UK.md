# Регламент перевірки релізу IROS2_0

## Обов'язкова автоматична перевірка

Автоматичний release verifier працює на Raspberry Pi 5 з Debian 13 Trixie
ARM64. Він перевіряє:

1. Завантаження `.deb` і `SHA256SUMS` з GitHub Release.
2. Відповідність SHA-256.
3. Чисте встановлення пакета через APT.
4. Запуск `ros2` у `bash --noprofile --norc` без успадкованого ROS
   environment.
5. Наявність `ros_base` і успішний `ros2 doctor --report`.
6. Ручну активацію `/opt/iros2_0/jazzy/setup.bash`.

RViz не входить до автоматичної перевірки. GUI запускається вручну на
цільовому обладнанні після встановлення релізу:

```bash
rviz2
```

## Нативна збірка

Повторний запуск продовжує збірку з уже завершених пакетів. Типово colcon
використовує два паралельні workers:

```bash
cd ~/iros2_0
./scripts/native/release-rpi.sh
```

Перший запуск на новій системі:

```bash
IROS2_INSTALL_DEPENDENCIES=1 ./scripts/native/release-rpi.sh
```

Кількість workers можна змінити:

```bash
IROS2_PARALLEL_WORKERS=3 ./scripts/native/build-rpi.sh
```

Для примусової повної перебудови:

```bash
IROS2_RESUME_BUILD=0 IROS2_CMAKE_CLEAN_CACHE=1 \
  ./scripts/native/build-rpi.sh
```

## Очищення після збірки

Після успішного створення `.deb` команда `build-package.sh` автоматично
видаляє проміжні каталоги `build/`, `log/`, Python bytecode і порожні
`__pycache__`. Вона зберігає:

- вихідні коди у `src/`;
- встановлений runtime у `/opt/iros2_0/jazzy`;
- `.deb` і `SHA256SUMS` у `artifacts/`.
- архів build-логів і загальний `native-release.log` у `artifacts/`.

Для GitHub Release створюються versioned-файл і стабільний asset:

```text
iros2-0_<version>_arm64.deb
iros2-0_latest_arm64.deb
iros2-0_latest_arm64.deb.sha256
SHA256SUMS
```

Після merge змін у `main` реліз публікується однією командою на Windows:

```powershell
.\scripts\release\publish-release.ps1
```

Скрипт перевіряє повний список assets, звіряє checksum стабільного пакета,
не дозволяє випадково перезаписати наявний tag і позначає новий реліз як
latest.

Очищення можна запустити окремо:

```bash
./scripts/native/cleanup-build.sh
```

Для діагностики невдалої збірки автоматичне очищення слід тимчасово
відключити:

```bash
IROS2_CLEAN_AFTER_PACKAGE=0 ./scripts/native/build-package.sh
```

Очищення запускається лише після успішного пакування. При помилці `build/`
і `log/` залишаються для аналізу та наступного resume-запуску.

## Автоматична перевірка встановленого пакета

```bash
export IROS2_VERIFY_INSTALLED_ONLY=1
./scripts/release/verify-native.sh
```

Повний цикл із GitHub Release:

```bash
export IROS2_RELEASE_TAG=v0.1.1
export IROS2_PACKAGE_VERSION=0.1.1-1+deb13
./scripts/release/verify-native.sh
```

## Критерій випуску

Реліз можна публікувати після успішної нативної збірки, перевірки checksum,
APT-встановлення та автоматичного ROS smoke-test. Перевірка RViz виконується
окремо вручну і не повинна зупиняти автоматичний release pipeline.
