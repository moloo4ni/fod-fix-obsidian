# Redmi Note 14 Pro 4G (obsidian) — GSI FOD Fix Magisk Module

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

Magisk / KernelSU / APatch module that fixes the Under-Display Fingerprint Sensor (FOD) on **Redmi Note 14 Pro 4G** (codename: `obsidian`) running LineageOS 23.0 GSI or other Android 15+ Treble GSI-based ROMs.

## Features

- **Dynamic Persist Alignment** — Remounts `/persist` as rw at boot, restores Jiiov calibration from `.bak` if the active bin is missing, and sets secure ownership/permissions (`system:system`, `0660`).
- **Low-Latency Polling Daemon** — Background daemon polls `fod_press_status` every 20ms to trigger instant Local HBM (High Brightness Mode) via disp_param.
- **Dynamic Backlight Boosting** — Reads the panel's factory max brightness ceiling and boosts backlight during fingerprint scans, restoring the previous level on finger release.
- **SELinux Enforcing Compatibility** — Sets world-readable/writable permissions (`0666`) on `/dev/*fp*`, `/dev/*jiiov*`, and relevant sysfs nodes so the Jiiov HAL can work under enforcing policy.
- **Phh GSI Integration** — Sets `persist.sys.phh.fod.*` and `ro.hardware.fp.fod.*` properties to align the scanner UI with the physical low-mount sensor.
- **sysfs Permission Hardening** — Unlocks `/sys/class/lcd/`, `/sys/class/mi_display/`, and `/sys/class/touch/` nodes so the GSI framework can control backlight and HBM without SELinux denials.

## Prerequisites

- Device: Redmi Note 14 Pro 4G (`obsidian`)
- ROM: Any Android 15+ GSI with phh-Treble support (LineageOS 23.0+ based GSIs)
- Root: Magisk (24+), KernelSU, or APatch

## Installation

1. Download the latest `.zip` from the [Releases](https://github.com/moloo4ni/fod-fix-obsidian/releases) page.
2. Flash the archive in Magisk / KernelSU / APatch manager.
3. Open **Phh Treble Settings** → **Xiaomi features** → enable **FOD** options.
4. Reboot.

## Local Building

```bash
git clone https://github.com/moloo4ni/fod-fix-obsidian.git
cd fod-fix-obsidian
zip -r FODFixObsidian-1.0.zip module.prop service.sh system.prop customize.sh daemon.sh uninstall.sh
```

The resulting `.zip` can be flashed directly on the device.

## CI/CD

Pushing a tag starting with `v` (e.g., `v1.0`) triggers [GitHub Actions](.github/workflows/build.yml) to build the zip and publish a release.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
