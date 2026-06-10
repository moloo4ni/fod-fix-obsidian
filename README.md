# Redmi Note 14 Pro 4G (obsidian) GSI Under-Display Fingerprint (FOD) Fix

This repository contains a Magisk / KernelSU / APatch module that corrects the Under-Display Fingerprint Sensor (FOD) registration, backlight synchronization, and calibration path blocks specifically for the Redmi Note 14 Pro 4G (codename: obsidian) running LineageOS 23.0 GSI or other Android 13+ GSIs.

## Features

- **Dynamic Persist Alignment:** Automatically remounts the `/persist` partition at boot as read-write to verify, restore, and set appropriate secure system ownership and permission matrices (`system:system`, `0660`) on Jiiov/ANC calibration files.
- **Low-Latency Polling Daemon:** Includes a background polling daemon checking the touch panel event state (`fod_press_status`) every 20ms to coordinate instant local High Brightness Mode (HBM) trigger offsets.
- **Dynamic Backlight Boosting:** Reads the hardware panel's maximum factory brightness ceiling and dynamically boosts global backlight parameters during active touch inputs, preserving previous screen brightness states upon finger release.
- **SELinux Enforcing Compatibility:** Configures security contexts and broad system-level character device permissions (`0666`) to ensure the sandboxed Jiiov HAL can open `/dev/xiaomi-fp` without policy conflicts under enforcing kernels.
- **Phh GSI Integration:** Sets essential framework properties to align SystemUI-drawn scanner coordinates with the physical position of the low-mount optical sensor under the glass.

## Installation

1. Go to the **Releases** section of this repository and download the latest zip archive.
2. Flash the zip file using Magisk, KernelSU, or APatch.
3. Open the **Phh Treble Settings** app on your device, navigate to **Xiaomi features**, and ensure that **FOD** options are active. (Note: The GSI may automatically hide global automatic brightness controls during active scanner operations to prevent optical calibration fluctuations).
4. Reboot your device to apply the changes cleanly.

## Local Building

You can easily pack the repository files into a flashable Magisk zip module using standard command-line tools.

### Packaging

To manually create a flashable zip package of this module, execute the following command in the root directory of the repository:

```bash
zip -r FODFixObsidian-1.0.zip module.prop service.sh system.prop
```

The resulting zip archive can be immediately transferred to your device and flashed.

## CI/CD

This repository is configured with GitHub Actions. Pushing a tag starting with `v` (e.g., `v1.0`) will automatically trigger the build pipeline, package the flashable zip archive, and publish a new GitHub Release.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
