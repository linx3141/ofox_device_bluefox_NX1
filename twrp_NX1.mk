#
# Copyright (C) 2026 The OrangeFox Recovery Project
# SPDX-License-Identifier: GPL-3.0-or-later
#

# Configure base.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Configure core_64_bit_only.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Configure virtual_ab compression.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Configure emulated_storage.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Configure twrp common.mk
$(call inherit-product, vendor/twrp/config/common.mk)

# Configure full_base_telephony.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from NX1 device
$(call inherit-product, device/bluefox/NX1/device.mk)

PRODUCT_DEVICE := NX1
PRODUCT_NAME := twrp_NX1
PRODUCT_BRAND := BLUEFOX
PRODUCT_MODEL := NX1
PRODUCT_MANUFACTURER := BLUEFOX

PRODUCT_GMS_CLIENTID_BASE := android-bluefox

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="sys_mssi_64_ww_armv82-user 15 AP3A.240905.015.A2 mp1rck6991v164P4 release-keys"

BUILD_FINGERPRINT := BLUEFOX/BF001/BLUEFOX:15/AP3A.240905.015.A2/2025_20260427:user/release-keys

# Theme
TW_STATUS_ICONS_ALIGN := center
