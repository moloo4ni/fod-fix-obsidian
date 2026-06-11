#!/system/bin/sh
# Technical FOD boot configuration and fast HBM daemon bridge for Xiaomi Obsidian

# Wait for boot completion
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Force-apply system properties
resetprop -n persist.sys.phh.fod.xiaomi true
resetprop -n persist.sys.phh.nodim true
resetprop -n persist.sys.phh.fod_color "ffffff"
resetprop -n ro.hardware.fp.fod true
resetprop -n ro.hardware.fp.fod.location "low"

# Remount persist partitions as read-write to allow file creation
mount -o remount,rw /mnt/vendor/persist 2>/dev/null
mount -o remount,rw /persist 2>/dev/null

# Restore Jiiov calibration files from backup if active bin is missing
JIIOV_DIR="/mnt/vendor/persist/fingerprint/jiiov"
if [ -d "$JIIOV_DIR" ]; then
    if [ -f "$JIIOV_DIR/jv_normalized_calibration.bin.bak" ] && [ ! -f "$JIIOV_DIR/jv_normalized_calibration.bin" ]; then
        # Preserve original system:system ownership and SELinux contexts using -a
        cp -a "$JIIOV_DIR/jv_normalized_calibration.bin.bak" "$JIIOV_DIR/jv_normalized_calibration.bin" 2>/dev/null
    fi
fi

# Fix permissions on Jiiov calibration files in persist partition WHILE STILL MOUNTED RW
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

# Safely restore read-only mount status of persist partitions AFTER all file operations
mount -o remount,ro /mnt/vendor/persist 2>/dev/null
mount -o remount,ro /persist 2>/dev/null

# Dynamic LHBM & allow_tx permissions bypass
find /sys/ -name "*lhbm*" -o -name "*allow_tx*" 2>/dev/null | while read -r node; do
    if [ -f "$node" ]; then
        chmod 0666 "$node" 2>/dev/null
        chown system:system "$node" 2>/dev/null
        echo "1" > "$node" 2>/dev/null
    fi
done

# Standard sysfs nodes permission adjustments
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

# Unlock fingerprint character devices in /dev/ to bypass SELinux Enforcing blocks
for dev in /dev/*fp* /dev/*fingerprint* /dev/*jiiov* /dev/*anc* /dev/xiaomi-touch; do
    if [ -e "$dev" ]; then
        chmod 0666 "$dev" 2>/dev/null
        chown system:system "$dev" 2>/dev/null
    fi
done

# High-speed FOD Daemon Bridge with 20ms Non-Buffered Polling (9 ON / 0 OFF)
(
    last_state="-1"
    orig_brightness=""
    
    # Locate touch status node
    FOD_STATUS=""
    for node in "/sys/class/touch/touch_dev/fod_press_status" "/sys/devices/virtual/touch/tp_dev/fod_press_status"; do
        if [ -f "$node" ]; then
            FOD_STATUS="$node"
            chmod 0666 "$node" 2>/dev/null
            chown system:system "$node" 2>/dev/null
            break
        fi
    done

    # Locate disp_param node
    DISP_PARAM=""
    for node in "/sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/disp_param" "/sys/class/mi_display/disp-DSI-0/disp_param" "/sys/devices/platform/10012000.dsi/disp_param"; do
        if [ -f "$node" ]; then
            DISP_PARAM="$node"
            chmod 0666 "$node" 2>/dev/null
            chown system:system "$node" 2>/dev/null
            break
        fi
    done

    # Locate brightness control and maximum factory capability nodes
    BRIGHTNESS_NODE=""
    for node in "/sys/class/mi_display/disp-DSI-0/backlight" "/sys/class/backlight/panel0-backlight/brightness"; do
        if [ -f "$node" ]; then
            BRIGHTNESS_NODE="$node"
            chmod 0666 "$node" 2>/dev/null
            chown system:system "$node" 2>/dev/null
            break
        fi
    done

    MAX_BRIGHTNESS_NODE=""
    for node in "/sys/class/mi_display/disp-DSI-0/factory_max_brightness" "/sys/class/backlight/panel0-backlight/max_brightness"; do
        if [ -f "$node" ]; then
            MAX_BRIGHTNESS_NODE="$node"
            chmod 0666 "$node" 2>/dev/null
            chown system:system "$node" 2>/dev/null
            break
        fi
    done

    if [ -n "$FOD_STATUS" ] && [ -n "$DISP_PARAM" ] && [ -n "$BRIGHTNESS_NODE" ]; then
        # Wait for panel brightness node to be ready (avoids race on early boot)
        if [ -n "$MAX_BRIGHTNESS_NODE" ]; then
            max_brightness=""
            _wait=0
            while [ $_wait -lt 50 ]; do
                max_brightness=$(cat "$MAX_BRIGHTNESS_NODE" 2>/dev/null)
                if [ -n "$max_brightness" ] && [ "$max_brightness" -gt 0 ] 2>/dev/null; then
                    break
                fi
                _wait=$((_wait + 1))
                sleep 0.1
            done
        fi
        while true; do
            current_state=$(cat "$FOD_STATUS" 2>/dev/null)
            if [ "$current_state" != "$last_state" ]; then
                if [ "$current_state" = "1" ]; then
                    orig_brightness=$(cat "$BRIGHTNESS_NODE" 2>/dev/null)
                    if [ -n "$MAX_BRIGHTNESS_NODE" ]; then
                        max_brightness=$(cat "$MAX_BRIGHTNESS_NODE" 2>/dev/null)
                    fi
                    if [ -n "$max_brightness" ]; then
                        echo "$max_brightness" > "$BRIGHTNESS_NODE" 2>/dev/null
                    fi
                    echo "09 1" > "$DISP_PARAM" 2>/dev/null
                    echo "02 1" > "$DISP_PARAM" 2>/dev/null
                elif [ "$current_state" = "0" ]; then
                    echo "09 0" > "$DISP_PARAM" 2>/dev/null
                    echo "02 0" > "$DISP_PARAM" 2>/dev/null
                    if [ -n "$orig_brightness" ]; then
                        echo "$orig_brightness" > "$BRIGHTNESS_NODE" 2>/dev/null
                    fi
                fi
                last_state="$current_state"
            fi
            sleep 0.02
        done
    fi
) &
