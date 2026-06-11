# Redmi Note 14 Pro 4G (obsidian) -- GSI FOD Fix

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

**English** | [**Русский**](#russian)

---

<a name="english"></a>

## English

Magisk / KernelSU / APatch module that enables the Under-Display Fingerprint Sensor (FOD) on **Redmi Note 14 Pro 4G** (codename `obsidian`) running LineageOS 23.0 GSI (Android 16) or other Android 16+ Treble GSI-based ROMs.

### Features

- **Low-Latency Polling Daemon** -- Background daemon polls `fod_press_status` every 20 ms and instantly triggers Local HBM (High Brightness Mode) via the `disp_param` sysfs interface.
- **Dynamic Backlight Boosting** -- Reads the panel factory max brightness ceiling and boosts the backlight during fingerprint scans, restoring the previous level on finger release.
- **Phh GSI Integration** -- Sets `persist.sys.phh.fod.*` and `ro.hardware.fp.fod.*` properties to align the scanner icon position and enable Xiaomi FOD quirks.
- **Sysfs Permission Hardening** -- Sets world-readable/writable permissions on `/dev/*fp*`, `/dev/*jiiov*`, `/sys/class/lcd/`, `/sys/class/mi_display/`, and `/sys/class/touch/` nodes so the Jiiov ANC HAL and GSI framework can operate without SELinux denials.
- **Persist Calibration Recovery** -- Remounts `/persist` as read-write at boot and restores Jiiov calibration data from `.bak` if the active calibration file is missing.

### Prerequisites

- Device: Redmi Note 14 Pro 4G (`obsidian`)
- ROM: Any Android 16+ GSI with phh-Treble support (LineageOS 23.0+ based GSIs)
- Root: Magisk (24+), KernelSU, or APatch

### Installation

1. Download the latest `.zip` from the [Releases](https://github.com/moloo4ni/fod-fix-obsidian/releases) page.
2. Flash the archive in Magisk / KernelSU / APatch manager.
3. Open **Phh Treble Settings** -> **Xiaomi features** -> enable **FOD** related options.
4. Reboot.

### Local Building

```bash
git clone https://github.com/moloo4ni/fod-fix-obsidian.git
cd fod-fix-obsidian
zip -r FODFixObsidian-1.0.zip module.prop service.sh system.prop customize.sh daemon.sh uninstall.sh
```

The resulting `.zip` can be flashed directly on the device.

### CI/CD

Pushing a tag starting with `v` (e.g., `v1.0`) triggers [GitHub Actions](.github/workflows/build.yml) to build the zip and publish a release.

### Known Limitations

- **Daemon persistence under KernelSU.** The polling daemon is killed after `service.sh` exits on KernelSU, even with `nohup` and `setsid`. The boot-time setup (properties, permissions) still applies, but backlight boosting and HBM cannot activate without the daemon. See [issue #4](https://github.com/moloo4ni/fod-fix-obsidian/issues/4).
- **odm-fp-daemon "fingerprint is idle" on GSI.** The Jiiov ANC fingerprint HAL (`odm-fp-daemon`) skips its own HBM enable with the message `"skip enable lhbm as fingerprint is idle"` during enrollment on GSI. The HAL state machine never leaves the idle state because the GSI framework does not send the expected initialization sequence over AIDL. This is a HAL-level issue and cannot be fixed from a shell module. See [issue #5](https://github.com/moloo4ni/fod-fix-obsidian/issues/5).
- **Phh FOD bridge may be incomplete.** The `persist.sys.phh.fod.xiaomi` property does not fully replicate the stock Xiaomi framework behaviour on this MediaTek platform.

### License

This project is licensed under the GNU General Public License v3.0 -- see the [LICENSE](LICENSE) file for details.

---

<a name="russian"></a>

## Русский

Magisk / KernelSU / APatch-модуль для включения подэкранного сканера отпечатков (FOD) на **Redmi Note 14 Pro 4G** (кодовое имя `obsidian`) под GSI-прошивками на базе LineageOS 23.0 (Android 16) и других Android 16+ Treble GSI.

### Возможности

- **Демон с низкой задержкой.** Фоновый процесс опрашивает `fod_press_status` каждые 20 мс и мгновенно включает Local HBM (подсветку сканера) через интерфейс `disp_param` в ядре.
- **Динамическое повышение яркости.** Во время сканирования яркость экрана временно выкручивается на аппаратный максимум, а после отпускания пальца возвращается к исходному уровню.
- **Интеграция с phh GSI.** Устанавливаются системные свойства `persist.sys.phh.fod.*` и `ro.hardware.fp.fod.*`, чтобы иконка сканера отображалась в правильном месте и были активированы Xiaomi-специфичные настройки FOD.
- **Настройка прав доступа.** Выставляются права `0666` на `/dev/*fp*`, `/dev/*jiiov*`, а также на узлы `/sys/class/lcd/`, `/sys/class/mi_display/` и `/sys/class/touch/`, чтобы HAL отпечатков и GSI-фреймворк могли работать без блокировок SELinux.
- **Восстановление калибровки Jiiov.** Раздел `/persist` перемонтируется в rw при загрузке. Если активный файл калибровки отсутствует, он восстанавливается из резервной копии `.bak`.

### Требования

- Устройство: Redmi Note 14 Pro 4G (`obsidian`)
- Прошивка: любая Android 16+ GSI с поддержкой phh-Treble (LineageOS 23.0+)
- Root: Magisk (24+), KernelSU или APatch

### Установка

1. Скачайте последний `.zip` со страницы [Releases](https://github.com/moloo4ni/fod-fix-obsidian/releases).
2. Установите архив через менеджер Magisk / KernelSU / APatch.
3. Откройте **Phh Treble Settings** -> **Xiaomi features** -> включите опции FOD.
4. Перезагрузите устройство.

### Локальная сборка

```bash
git clone https://github.com/moloo4ni/fod-fix-obsidian.git
cd fod-fix-obsidian
zip -r FODFixObsidian-1.0.zip module.prop service.sh system.prop customize.sh daemon.sh uninstall.sh
```

Полученный `.zip` можно устанавливать на устройство.

### CI/CD

Пуш тега, начинающегося с `v` (например, `v1.0`), запускает [GitHub Actions](.github/workflows/build.yml): архив собирается и релиз публикуется автоматически.

### Известные ограничения

- **Демон не выживает после service.sh в KernelSU.** Процесс демона завершается после выхода `service.sh`, несмотря на `nohup` и `setsid`. Установка свойств и прав доступа при этом работает, но без демона не работают повышение яркости и HBM. См. [issue #4](https://github.com/moloo4ni/fod-fix-obsidian/issues/4).
- **odm-fp-daemon пропускает HBM: "fingerprint is idle".** Проприетарный HAL от Jiiov (`odm-fp-daemon`) логирует `"skip enable lhbm as fingerprint is idle"` при попытке записи отпечатка на GSI. HAL не выходит из состояния простоя, потому что GSI-фреймворк не отправляет ему правильную последовательность инициализации через AIDL. Это проблема уровня HAL, shell-модуль её не исправит -- требуется патч ядра или HAL. См. [issue #5](https://github.com/moloo4ni/fod-fix-obsidian/issues/5).
- **Интеграция phh FOD неполная.** Свойство `persist.sys.phh.fod.xiaomi` не полностью замещает стоковый фреймворк Xiaomi на платформе MediaTek.

### Лицензия

Этот проект распространяется под лицензией GNU General Public License v3.0 -- подробнее в файле [LICENSE](LICENSE).
