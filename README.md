# Redmi Note 14 Pro 4G (obsidian) FOD Fix

[![GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

[English](#english) | [Русский](#russian)

---

<a name="english"></a>
## English

Magisk / KernelSU / APatch module that enables the under-display fingerprint sensor (FOD) on the Redmi Note 14 Pro 4G (codename: obsidian) running LineageOS GSI or other Android 16+ Treble GSI-based ROMs.

### Features

- **Low-latency polling daemon** -- background process reads `fod_press_status` every 20 ms and instantly triggers local HBM (high brightness mode) via the `disp_param` sysfs interface.
- **Dynamic backlight boosting** -- reads the panel factory max brightness ceiling and boosts the backlight during fingerprint scans, restoring the previous level on finger release.
- **Phh GSI integration** -- sets `persist.sys.phh.fod.*` and `ro.hardware.fp.fod.*` properties to align the scanner icon position and enable Xiaomi FOD quirks.
- **Sysfs permission hardening** -- sets world-readable/writable permissions on `/dev/*fp*`, `/dev/*jiiov*`, `/sys/class/lcd/`, `/sys/class/mi_display/`, and `/sys/class/touch/` nodes so the Jiiov ANC HAL and GSI framework can operate without SELinux denials.
- **Persist calibration recovery** -- remounts `/persist` as read-write at boot and restores Jiiov calibration data from `.bak` if the active calibration file is missing.
- **Clean uninstall** -- reverts all sysfs permissions and device node modes to their defaults when the module is removed.

### Prerequisites

- Device: Redmi Note 14 Pro 4G (obsidian)
- ROM: any Android 16+ GSI with phh-Treble support (LineageOS 23.0+ based GSIs)
- Root: Magisk 24+, KernelSU, or APatch

### Installation

1. Download the latest zip from the [Releases](https://github.com/moloo4ni/fod-fix-obsidian/releases) page.
2. Flash it in Magisk, KernelSU, or APatch.
3. Open **Phh Treble Settings** -> **Xiaomi features** and enable the relevant FOD options.
4. Reboot.

### Building from source

```bash
zip -r FODFixObsidian-<version>.zip \
  module.prop service.sh system.prop customize.sh daemon.sh uninstall.sh
```

The flashable zip can be installed directly on the device.

### Module structure

```
module.prop         Module metadata
service.sh          Boot-time property setup, permissions, daemon launch
system.prop         System property overrides
customize.sh        Magisk/KSU/APatch install-time hook
daemon.sh           Persistent FOD polling daemon
uninstall.sh        Permission and sysfs cleanup on removal
```

### CI/CD

Pushing a `v*` tag triggers GitHub Actions, which creates the zip archive and publishes a release.

### Known limitations

- **Daemon killed after service.sh exits on KernelSU.** The polling daemon does not survive beyond `service.sh` on KernelSU even with `nohup` and `setsid`. Boot-time properties and permissions still apply, but backlight boosting and HBM cannot activate without the daemon.
- **odm-fp-daemon skips HBM: 'fingerprint is idle' on GSI.** The proprietary Jiiov ANC HAL (`odm-fp-daemon`) logs `"skip enable lhbm as fingerprint is idle"` during enrollment on GSI. The HAL never leaves the idle state because the GSI framework does not send the expected AIDL initialisation sequence. This is a HAL-level issue and cannot be fixed from a shell module.
- **Phh FOD bridge may be incomplete.** The `persist.sys.phh.fod.xiaomi` property does not fully replicate the stock Xiaomi framework behaviour on this MediaTek platform.

### License

[GNU General Public License v3.0](LICENSE)

---

<a name="russian"></a>
## Русский

Модуль для Magisk / KernelSU / APatch, включающий подэкранный сканер отпечатков (FOD) на Redmi Note 14 Pro 4G (obsidian) под GSI-прошивками на базе LineageOS GSI (Android 16+) и других Android 16+ Treble GSI.

### Возможности

- **Демон с низкой задержкой** -- фоновый процесс опрашивает `fod_press_status` каждые 20 мс и мгновенно включает local HBM (подсветку сканера) через интерфейс `disp_param` в ядре.
- **Динамическое повышение яркости** -- во время сканирования яркость экрана временно выкручивается на аппаратный максимум, после отпускания пальца возвращается к исходному уровню.
- **Интеграция с phh GSI** -- устанавливаются системные свойства `persist.sys.phh.fod.*` и `ro.hardware.fp.fod.*`, чтобы иконка сканера отображалась в правильном месте и были активированы Xiaomi-специфичные настройки FOD.
- **Настройка прав доступа** -- выставляются права 0666 на `/dev/*fp*`, `/dev/*jiiov*`, а также на узлы `/sys/class/lcd/`, `/sys/class/mi_display/` и `/sys/class/touch/`, чтобы HAL отпечатков и GSI-фреймворк могли работать без блокировок SELinux.
- **Восстановление калибровки Jiiov** -- раздел `/persist` перемонтируется в rw при загрузке. Если активный файл калибровки отсутствует, он восстанавливается из резервной копии `.bak`.
- **Чистое удаление** -- при деинсталляции модуля все права sysfs и режимы устройств возвращаются к стандартным значениям.

### Требования

- Устройство: Redmi Note 14 Pro 4G (obsidian)
- Прошивка: любая Android 16+ GSI с поддержкой phh-Treble (LineageOS 23.0+)
- Root: Magisk 24+, KernelSU или APatch

### Установка

1. Скачайте последний zip-архив из [Releases](https://github.com/moloo4ni/fod-fix-obsidian/releases).
2. Установите через Magisk, KernelSU или APatch.
3. Откройте **Phh Treble Settings** -> **Xiaomi features** и включите соответствующие опции FOD.
4. Перезагрузите устройство.

### Сборка из исходников

```bash
zip -r FODFixObsidian-<версия>.zip \
  module.prop service.sh system.prop customize.sh daemon.sh uninstall.sh
```

Полученный zip-файл можно устанавливать на устройство.

### Структура модуля

```
module.prop         Метаданные модуля
service.sh          Установка свойств, прав доступа и запуск демона при загрузке
system.prop         Переопределение системных свойств
customize.sh        Хук установки Magisk/KSU/APatch
daemon.sh           Постоянный демон опроса FOD
uninstall.sh        Сброс прав доступа и sysfs при удалении
```

### CI/CD

При пуше тега вида `v*` GitHub Actions автоматически собирает zip-архив и публикует релиз.

### Известные ограничения

- **Демон не выживает после service.sh в KernelSU.** Процесс демона завершается после выхода `service.sh`, несмотря на `nohup` и `setsid`. Установка свойств и прав доступа при этом работает, но без демона не работают повышение яркости и HBM.
- **odm-fp-daemon пропускает HBM: 'fingerprint is idle'.** Проприетарный HAL от Jiiov (`odm-fp-daemon`) логирует `"skip enable lhbm as fingerprint is idle"` при попытке записи отпечатка на GSI. HAL не выходит из состояния простоя, потому что GSI-фреймворк не отправляет ему правильную последовательность инициализации через AIDL. Это проблема уровня HAL, shell-модуль её не исправит.
- **Интеграция phh FOD неполная.** Свойство `persist.sys.phh.fod.xiaomi` не полностью замещает стоковый фреймворк Xiaomi на платформе MediaTek.

### Лицензия

[GNU General Public License v3.0](LICENSE)
