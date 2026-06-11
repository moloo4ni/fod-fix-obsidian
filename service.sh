#!/system/bin/sh
MODDIR=${0%/*}

# Phase 1 — apply system properties
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

resetprop -n persist.sys.phh.fod.xiaomi true
resetprop -n persist.sys.phh.nodim true
resetprop -n persist.sys.phh.fod_color "ffffff"
resetprop -n ro.hardware.fp.fod true
resetprop -n ro.hardware.fp.fod.location "low"

# Phase 2 — persist partition & calibration files
mount -o remount,rw /mnt/vendor/persist 2>/dev/null
mount -o remount,rw /persist 2>/dev/null

JIIOV_DIR="/mnt/vendor/persist/fingerprint/jiiov"
if [ -d "$JIIOV_DIR" ]; then
    if [ -f "$JIIOV_DIR/jv_normalized_calibration.bin.bak" ] && [ ! -f "$JIIOV_DIR/jv_normalized_calibration.bin" ]; then
        cp -a "$JIIOV_DIR/jv_normalized_calibration.bin.bak" "$JIIOV_DIR/jv_normalized_calibration.bin" 2>/dev/null
    fi
fi

PERSIST_FP_DIRS=(
    "/mnt/vendor/persist/fingerprint"
    "/mnt/vendor/persist/fingerprint/jiiov"
    "/persist/fingerprint"
    "/persist/fingerprint/jiiov"
    "/data/vendor/fingerprint"
)

for dir in "${PERSIST_FP_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        chmod 0775 "$dir" 2>/dev/null
        chown -R system:system "$dir" 2>/dev/null
        chmod 0660 "$dir"/* 2>/dev/null
    fi
done

mount -o remount,ro /mnt/vendor/persist 2>/dev/null
mount -o remount,ro /persist 2>/dev/null

# Phase 3 — sysfs and device node permissions
find /sys/ -name "*lhbm*" -o -name "*allow_tx*" 2>/dev/null | while read -r node; do
    if [ -f "$node" ]; then
        chmod 0666 "$node" 2>/dev/null
        chown system:system "$node" 2>/dev/null
        echo "1" > "$node" 2>/dev/null
    fi
done

NODES=(
    "/sys/class/lcd/panel/actual_mask_brightness"
    "/sys/class/lcd/panel/mask_brightness"
    "/sys/class/mi_display/disp-DSI-0/disp_param"
    "/sys/class/mi_display/disp-DSI-0/brightness"
    "/sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/disp_param"
    "/sys/devices/platform/10012000.dsi/disp_param"
    "/sys/class/touch/touch_dev/fod_press_status"
    "/sys/devices/platform/soc/soc:fpc_fpc1020/irq"
    "/sys/devices/platform/soc/soc:fpc_fpc1020/irq_enable"
    "/sys/devices/platform/soc/soc:fpc_fpc1020/wakelock_enable"
)

for node in "${NODES[@]}"; do
    if [ -e "$node" ]; then
        chmod 0666 "$node" 2>/dev/null
        chown system:system "$node" 2>/dev/null
    fi
done

for dev in /dev/*fp* /dev/*fingerprint* /dev/*jiiov* /dev/*anc* /dev/xiaomi-touch; do
    if [ -e "$dev" ]; then
        chmod 0666 "$dev" 2>/dev/null
        chown system:system "$dev" 2>/dev/null
    fi
done

# Phase 4 — launch persistent polling daemon (separate file avoids quoting issues)
nohup /system/bin/sh "$MODDIR/daemon.sh" >/dev/null 2>&1 &
