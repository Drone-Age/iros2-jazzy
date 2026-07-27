# Політика пакетів `iros2j`

Ця політика визначає погоджену ціль v1. Вона не стверджує, що поточна
реалізація 0.1.x уже відповідає цим вимогам.

## Ідентичність і платформа

- Namespace Debian-пакетів: `iros2j`.
- Внутрішній ROS distribution: `jazzy`; зберігається `ROS_DISTRO=jazzy`.
- Спільний install prefix: `/opt/iros2j`.
- Підтримувана бінарна платформа: Debian 13 Trixie ARM64 (`arm64`/`aarch64`).
- Незалежні від архітектури пакети можуть мати `Architecture: all`.
- AMD64 не збирається, не тестується, не документується і не підтримується.
- Звичайні релізи збираються нативно; Docker і QEMU не є release-шляхами.

## Один ROS-пакет — один Debian-пакет

Кожен ROS-пакет постачається окремим Debian-пакетом зі структурою володіння
вмістом у стилі офіційного ROS: runtime libraries/executables, headers,
resource index entries, interfaces, Python modules і CMake/package metadata
належать відповідному пакету. Один глобальний development-пакет заборонений.

Детерміноване перетворення імен:

```text
ros-jazzy-<normalized-name>  ->  iros2j-<normalized-name>
```

Підкреслення в імені ROS-пакета перетворюються на Debian-дефіси. `jazzy` не
входить до власного імені пакета. Приклади:

| ROS / офіційний пакет | Debian-пакет `iros2j` |
|---|---|
| `ros_core` / `ros-jazzy-ros-core` | `iros2j-ros-core` |
| `rclcpp` / `ros-jazzy-rclcpp` | `iros2j-rclcpp` |
| `sensor_msgs` / `ros-jazzy-sensor-msgs` | `iros2j-sensor-msgs` |
| `cv_bridge` / `ros-jazzy-cv-bridge` | `iros2j-cv-bridge` |
| `rviz2` / `ros-jazzy-rviz2` | `iros2j-rviz2` |

ROS-залежність `<depend>rclcpp</depend>` перетворюється на точну залежність
snapshot, наприклад `iros2j-rclcpp (= 1.0.1-1+deb13)`.

## Метапакети

Початковий набір метапакетів:

- `iros2j-ros-core`
- `iros2j-ros-base`
- `iros2j-common-interfaces`
- `iros2j-vision-opencv`
- `iros2j-rviz2`

`iros2j-desktop` можна додати лише тоді, коли замикання його залежностей
відповідає офіційному ROS variant. Метапакети містять metadata залежностей, а
не скопійований payload пакетів-учасників.

## Заборонений legacy і хибна сумісність

Монолітні пакети `iros2-0`, `iros2-core`, `iros2-interfaces`, `iros2-vision`,
`iros2-rviz` та `iros2-development` видаляються у v1. Їх не можна відтворювати
під namespace `iros2j`.

Не можна оголошувати `Provides: ros-jazzy-*`, доки шляхи, ownership і
сумісність відрізняються від офіційних пакетів. Перехід із 0.1.x має
використовувати явне видалення/conflict і перевірку чистого встановлення.

## Поширення репозиторію

Підтримуваний спосіб доставки — підписаний APT repository з metadata
`Packages`, `Release` і checksums. GitHub Release містить repository або
bootstrap bundle, `SHA256SUMS`, component/source manifest, SBOM, release notes
та gate evidence. Не можна публікувати сотні неструктурованих `.deb` assets.
