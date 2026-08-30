#
# Copyright (C) 2026 The OrangeFox Recovery Project
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Bluefox NX1 - MediaTek MT6768 (Helio G81), Virtual A/B, GKI 4K pages
# Values taken from the PixelOS 17 device tree (device/bluefox/NX1).
#

DEVICE_PATH := device/bluefox/NX1
KERNEL_PATH := $(DEVICE_PATH)/kernel

# Minimal-manifest build tweaks (same as the oneplus/dodge tree)
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PLUGIN_VALIDATION := \
    soong-libaosprecovery_defaults \
    soong-libguitwrp_defaults \
    soong-libminuitwrp_defaults \
    soong-vold_defaults

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a75
TARGET_SUPPORTS_64_BIT_APPS := true

# Bootloader / platform
TARGET_NO_BOOTLOADER := true
TARGET_BOOTLOADER_BOARD_NAME := mt6768
TARGET_BOARD_PLATFORM := mt6768
PRODUCT_PLATFORM := mt6768

# Prebuilt GKI kernel (from the PixelOS 17 NX1-kernel repo)
BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_PREBUILT_KERNEL := $(KERNEL_PATH)/$(BOARD_KERNEL_IMAGE_NAME)
BOARD_KERNEL_PAGESIZE := 4096
BOARD_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := $(BOARD_BOOT_HEADER_VERSION)
BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(KERNEL_PATH)/dtb
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PATH)/dtbo.img
BOARD_RAMDISK_USE_LZ4 := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

BOARD_MKBOOTIMG_ARGS := --base 0x00000000
BOARD_MKBOOTIMG_ARGS += --kernel_offset 0x40080000
BOARD_MKBOOTIMG_ARGS += --pagesize 4096
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset 0x47c80000
BOARD_MKBOOTIMG_ARGS += --tags_offset 0x4bc80000
BOARD_MKBOOTIMG_ARGS += --dtb_offset 0x4bc80000
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.serialconsole=0 loglevel=8
BOARD_BOOTCONFIG := androidboot.serialconsole=0

# A/B (Virtual A/B with vendor ramdisk, like the stock ROM)
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS := \
    boot \
    dtbo \
    init_boot \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

# Dynamic partitions (stock super layout; PRODUCT_USE_DYNAMIC_PARTITIONS is
# set in device.mk)
BOARD_SUPER_PARTITION_SIZE := 9663676416
BOARD_SUPER_PARTITION_GROUPS := bluefox_dynamic_partitions
BOARD_BLUEFOX_DYNAMIC_PARTITIONS_SIZE := 9661579264
BOARD_BLUEFOX_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vendor \
    vendor_dlkm

# TARGET_COPY_OUT_VENDOR=vendor makes BOARD_USES_VENDORIMAGE true so the
# recovery root gets a real /vendor directory instead of a symlink (the
# device tree ships TEE blobs there).
TARGET_COPY_OUT_VENDOR := vendor

# Partition sizes (stock)
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

# The NX1 has no dedicated recovery partition: recovery lives inside
# vendor_boot (VAB + GKI), exactly like the PixelOS 17 tree.
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
BOARD_USES_METADATA_PARTITION := true

# The system vendor ramdisk is now provided verbatim by
# device/bluefox/NX1/prebuilt_vendor_ramdisk (see device.mk), so recovery
# kernel modules must NOT be injected into it. Recovery-specific modules are
# shipped inside the recovery ramdisk instead (recovery/root/lib/modules).

# Verified boot (test keys, same as the ROM tree)
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA2048
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
# Match PixelOS: the vendor_boot gets a hash-only AVB footer (algorithm NONE,
# no signature, rollback index 0) instead of a test-key signature.
BOARD_AVB_VENDOR_BOOT_ALGORITHM := NONE

# File systems
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# TWRP display (540x1168 @ 240dpi; brightness path is the usual MTK one)
TARGET_SCREEN_WIDTH := 540
TARGET_SCREEN_HEIGHT := 1168
TARGET_SCREEN_DENSITY := 240
TW_THEME := portrait_hdpi
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_DEFAULT_BRIGHTNESS := 80
TW_MAX_BRIGHTNESS := 255
TW_SCREEN_BLANK_ON_BOOT := true
# No CPU thermal zone in recovery (only charger/gauge zones exist); show the
# mtk-gauge temperature instead of an invalid 0 degC.
TW_CUSTOM_CPU_TEMP_PATH := "/sys/class/thermal/thermal_zone6/temp"

# Crypto / decryption (FBE with metadata encryption, TrustKernel keymint).
# TrustKernel teed/keymint/gatekeeper and keystore2 are vendored into the
# recovery ramdisk (recovery/root/vendor + keystore2 service in
# init.recovery.mt6768.rc). Verified working: metadata auto-decrypts and the
# lock-screen PIN page decrypts /data.
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY := true

# MTP is enabled (TW_HAS_MTP). The musb configfs switch is handled in
# recovery/root/init.recovery.usb.rc: mtp,adb binds only after the MTP server
# signals sys.usb.ffs.mtp.ready, and the adb ready flag is kept across
# switches so neither direction drops the USB connection.

# Tools
TW_INCLUDE_FASTBOOTD := true
TW_SKIP_ADDITIONAL_FSTAB := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_LPDUMP := true
TW_INCLUDE_LPTOOLS := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
RECOVERY_SDCARD_ON_DATA := true
TARGET_USES_MKE2FS := true
TW_ENABLE_FS_COMPRESSION := true
TW_INCLUDE_FUSE_EXFAT := true
TW_INCLUDE_FUSE_NTFS := true
TW_INCLUDE_NTFS_3G := true
TW_NO_EXFAT_FUSE := true

# Touch (JADARD JD9365 TDDI). Modules live in the vendor ramdisk; these are
# also listed for TWRP's vendor_dlkm loader after mounting the partitions.
TW_LOAD_VENDOR_MODULES := "jd9365tg_i2c.ko jd9365tn_i2c.ko touch_boost.ko mtk_ioctl_touch_boost.ko"
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI := true

# Haptics: the regulator-vibrator driver exposes a plain LED class device.
# The ledtrig-transient path (duration/activate) leaves brightness at 255 and
# the motor stuck on, so use short brightness on/off pulses instead. The
# duration comes from the OrangeFox Settings -> Vibration sliders
# (tw_button_vibrate / tw_keyboard_vibrate / tw_action_vibrate).
TW_HAPTICS_LED_BRIGHTNESS := /sys/class/leds/vibrator/brightness
TW_HAPTICS_LED_MAX_BRIGHTNESS := /sys/class/leds/vibrator/max_brightness

# Misc TWRP settings
TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID := true
TW_USE_TOOLBOX := true
TW_DEFAULT_LANGUAGE := en
TW_EXTRA_LANGUAGES := true
TW_EXCLUDE_APEX := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TARGET_RECOVERY_DEVICE_MODULES += debuggerd
TARGET_RECOVERY_DEVICE_MODULES += strace
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/debuggerd
RECOVERY_BINARY_SOURCE_FILES += $(TARGET_OUT_EXECUTABLES)/strace

BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

TW_DEVICE_VERSION := Bluefox_NX1

# Recovery-only version hacks (same trick as the oneplus/dodge tree)
PLATFORM_VERSION := 99.87.36
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
