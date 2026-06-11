#!/system/bin/sh
# Persistent FOD polling daemon — reads fod_press_status and controls
# disp_param (local_hbm, hbm_fod, fod_calibration) + backlight boost.

last_state="-1"
orig_brightness=""

FOD_STATUS=""
for node in "/sys/class/touch/touch_dev/fod_press_status" "/sys/devices/virtual/touch/tp_dev/fod_press_status"; do
    if [ -f "$node" ]; then
        FOD_STATUS="$node"
        chmod 0666 "$node" 2>/dev/null
        chown system:system "$node" 2>/dev/null
        break
    fi
done

DISP_PARAM=""
for node in "/sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/disp_param" "/sys/class/mi_display/disp-DSI-0/disp_param" "/sys/devices/platform/10012000.dsi/disp_param"; do
    if [ -f "$node" ]; then
        DISP_PARAM="$node"
        chmod 0666 "$node" 2>/dev/null
        chown system:system "$node" 2>/dev/null
        break
    fi
done

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
                    echo "04 $max_brightness" > "$DISP_PARAM" 2>/dev/null
                fi
                echo "05 1" > "$DISP_PARAM" 2>/dev/null
                echo "02 1" > "$DISP_PARAM" 2>/dev/null
                echo "09 1" > "$DISP_PARAM" 2>/dev/null
            elif [ "$current_state" = "0" ]; then
                echo "05 0" > "$DISP_PARAM" 2>/dev/null
                echo "02 0" > "$DISP_PARAM" 2>/dev/null
                echo "09 0" > "$DISP_PARAM" 2>/dev/null
                echo "04 0" > "$DISP_PARAM" 2>/dev/null
                if [ -n "$orig_brightness" ]; then
                    echo "$orig_brightness" > "$BRIGHTNESS_NODE" 2>/dev/null
                fi
            fi
            last_state="$current_state"
        fi
        sleep 0.02
    done
fi
