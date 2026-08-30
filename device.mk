#
# Copyright (C) 2026 The OrangeFox Recovery Project
# SPDX-License-Identifier: GPL-3.0-or-later
#

LOCAL_PATH := device/bluefox/NX1

# Build-time source patches for the OrangeFox tree (mirrors the PixelOS 17
# device tree mechanism). Each patch is applied idempotently with git apply:
# --check fails when the patch is already applied, so repeated builds are
# no-ops. See device/bluefox/NX1/patches/ for the individual diffs.
$(shell \
  for spec in \
    "bootable/recovery:0001-bootable-recovery-mtk-flashlight.patch" \
    "bootable/recovery:0002-bootable-recovery-lockscreen-gesture-scale.patch" \
    "bootable/recovery:0004-bootable-recovery-led-vibrator.patch" \
    "bootable/recovery:0013-bootable-recovery-mtp-udc-retry.patch" \
    "bootable/recovery:0014-bootable-recovery-libvintf-recovery.patch" \
    "bootable/recovery:0015-bootable-recovery-skip-ab-system-mount.patch" \
    "system/core:0005-system-core-fastbootd-no-hal.patch" \
    "system/libvintf:0006-system-libvintf-meta-v9.patch" \
    "frameworks/native:0007-frameworks-native-servicemanager-vintf-skip.patch" \
    "frameworks/native:0008-frameworks-native-libbinder-ndk36.patch" \
    "external/libcxx:0009-external-libcxx-verbose-abort.patch" \
  ; do \
    repo=$${spec%%:*}; f=$${spec##*:}; \
    (cd $$repo && git apply --check $(CURDIR)/device/bluefox/NX1/patches/$$f 2>/dev/null && git apply $(CURDIR)/device/bluefox/NX1/patches/$$f 2>/dev/null) || true; \
  done)

# Shipping API level / vendor surface. The fox_14.1 minimal manifest only
# provides BOARD_SYSTEMSDK_VERSIONS=34, so keep recovery at 34 (this is a
# recovery image; the ROM itself stays on the stock API-35 vendor surface).
BOARD_SHIPPING_API_LEVEL := 34
PRODUCT_SHIPPING_API_LEVEL := 34
PRODUCT_TARGET_VNDK_VERSION := 34

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_PACKAGES += \
    lpflash \
    lpmake \
    lpunpack

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)

# The system-side vendor ramdisk (vendor_ramdisk00 in vendor_boot) must be
# byte-for-byte identical to PixelOS's own vendor_boot, otherwise the PixelOS
# system boots with a foreign ramdisk (wrong first-stage fstab, missing
# vendor/firmware, different modules.load, ...). Copy PixelOS's final
# vendor_ramdisk00 content here verbatim.
PREBUILT_VENDOR_RAMDISK_DIR := $(LOCAL_PATH)/prebuilt_vendor_ramdisk
PRODUCT_COPY_FILES += \
    $(foreach f,$(shell cd $(PREBUILT_VENDOR_RAMDISK_DIR) && find . -type f),$(PREBUILT_VENDOR_RAMDISK_DIR)/$(patsubst ./%,%,$(f)):$(TARGET_COPY_OUT_VENDOR_RAMDISK)/$(patsubst ./%,%,$(f)))

# OrangeFox-specific settings (OF_* variables are make-processed)
$(call inherit-product, $(LOCAL_PATH)/fox_NX1.mk)
