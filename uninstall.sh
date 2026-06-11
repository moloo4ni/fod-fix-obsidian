#!/system/bin/sh

# Reset sysfs permissions modified by this module
for node in \
  /sys/class/lcd/panel/actual_mask_brightness \
  /sys/class/lcd/panel/mask_brightness \
  /sys/class/mi_display/disp-DSI-0/disp_param \
  /sys/class/mi_display/disp-DSI-0/brightness \
  /sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/disp_param \
  /sys/devices/platform/10012000.dsi/disp_param \
  /sys/class/touch/touch_dev/fod_press_status \
  /sys/devices/platform/soc/soc:fpc_fpc1020/irq \
  /sys/devices/platform/soc/soc:fpc_fpc1020/irq_enable \
  /sys/devices/platform/soc/soc:fpc_fpc1020/wakelock_enable; do
  if [ -e "$node" ]; then
    chmod 0644 "$node" 2>/dev/null
  fi
done

# Reset disp_param to safe default
for node in /sys/devices/virtual/mi_display/disp_feature/disp-DSI-0/disp_param \
            /sys/class/mi_display/disp-DSI-0/disp_param \
            /sys/devices/platform/10012000.dsi/disp_param; do
  if [ -f "$node" ]; then
    echo "0" > "$node" 2>/dev/null
  fi
done

# Reset character device permissions
for dev in /dev/*fp* /dev/*fingerprint* /dev/*jiiov* /dev/*anc* /dev/xiaomi-touch; do
  if [ -e "$dev" ]; then
    chmod 0660 "$dev" 2>/dev/null
  fi
done

# Reset lhbm / allow_tx nodes
find /sys/ -name "*lhbm*" -o -name "*allow_tx*" 2>/dev/null | while read -r node; do
  if [ -f "$node" ]; then
    chmod 0644 "$node" 2>/dev/null
  fi
done
