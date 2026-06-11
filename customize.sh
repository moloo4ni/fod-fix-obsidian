#!/system/bin/sh

# Clean up old overlay that is no longer shipped with this module
if pm list packages 2>/dev/null | grep -q com.moloo4ni.obsidian.fod.overlay; then
    pm uninstall com.moloo4ni.obsidian.fod.overlay >/dev/null 2>&1
    cmd overlay disable com.moloo4ni.obsidian.fod.overlay >/dev/null 2>&1
fi

# Remove legacy overlay APK if present
rm -f /data/app/com.moloo4ni.obsidian.fod.overlay* 2>/dev/null
rm -rf /data/data/com.moloo4ni.obsidian.fod.overlay 2>/dev/null

# Clean stale cache artifacts
rm -f /data/resource-cache/*com.moloo4ni.obsidian.fod* 2>/dev/null
rm -f /cache/*com.moloo4ni.obsidian.fod* 2>/dev/null

# Set module file permissions
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
