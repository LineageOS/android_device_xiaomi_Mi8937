#
# Copyright (C) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(USES_DEVICE_XIAOMI_MI8937),true)
include $(call all-makefiles-under,$(LOCAL_PATH))

endif
