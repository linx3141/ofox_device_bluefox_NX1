#
# Copyright (C) 2026 The OrangeFox Recovery Project
# SPDX-License-Identifier: GPL-3.0-or-later
#

OF_MAINTAINER := linx3141
OF_SCREEN_W := 540
# OF_SCREEN_H is the theme's scaled design height, not the physical height:
# physical 540x1168 = 9:19.47 aspect => 19.47*120 = 2336. This makes the
# 1080x1920 theme scale uniformly (0.5x/0.5x) instead of 0.5x/1.0x.
OF_SCREEN_H := 2336
# Status bar height is also the top safe-area inset for the camera cutout.
# 256 (design px) keeps the icons and page content below the punch-hole.
OF_STATUS_H := 224
OF_HIDE_NOTCH := 1
OF_STATUS_INDENT_LEFT := 40
OF_STATUS_INDENT_RIGHT := 20
OF_OPTIONS_LIST_NUM := 6
OF_USE_GREEN_LED := 0

OF_ENABLE_ALL_PARTITION_TOOLS := 1
OF_WORKAROUND_BACKUP_BUG := 1
OF_FORCE_DATA_FORMAT_F2FS := 1
OF_UNBIND_SDCARD_F2FS := 1
OF_WIPE_METADATA_AFTER_DATAFORMAT := 1
OF_DYNAMIC_FULL_SIZE := 9663676416
OF_DISPLAY_FORMAT_FILESYSTEMS_DEBUG_INFO := 1
OF_FORCE_PREBUILT_KERNEL := 1
OF_NO_RELOAD_AFTER_DECRYPTION := 1
OF_NO_TREBLE_COMPATIBILITY_CHECK := 1
OF_USE_LZ4_COMPRESSION := 1
OF_ENABLE_FS_COMPRESSION := 1

# Flashlight: MTK flashlight_core sysfs interface (flashlight_torch file),
# with the driver modules loaded from the recovery vendor ramdisk.
OF_FLASHLIGHT_ENABLE := 1
OF_FL_PATH1 := /sys/class/flashlight_core/flashlight

# MTK: the AIDL/HIDL health service is not available in the recovery ramdisk,
# so the default health-based battery reader always reports 100%. Read the
# mtk-gauge sysfs nodes directly instead (real capacity/status).
OF_USE_LEGACY_BATTERY_SERVICES := 1

# MTK AIDL boot control HAL is vendored from the stock recovery ramdisk
OF_USE_AIDL_BOOT_CONTROL := 1

# Do not mount /system_root or /vendor before update_engine_sideload: on VAB
# devices the mounted snapshot device makes cleanup fail with EBUSY.
OF_SKIP_AB_SYSTEM_MOUNT := 1

# TrustKernel provides AIDL keymint v3 in the stock ROM.
OF_DEFAULT_KEYMASTER_VERSION := 3
