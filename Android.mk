#
# Copyright (C) 2026 The OrangeFox Recovery Project
# SPDX-License-Identifier: GPL-3.0-or-later
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),NX1)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
