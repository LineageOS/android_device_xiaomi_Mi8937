#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Cryptfshw
TARGET_EXCLUDE_CRYPTFSHW := true

# Inherit from mithorium-common
$(call inherit-product, device/xiaomi/mithorium-common/mithorium.mk)
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# Boot animation
TARGET_SCREEN_HEIGHT := 1280
TARGET_SCREEN_WIDTH := 720

# Dynamic Partitions
PRODUCT_BUILD_SUPER_PARTITION := false
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_RETROFIT_DYNAMIC_PARTITIONS := true

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(LOCAL_PATH)/overlay

ifeq ($(PRODUCT_HARDWARE),Mi8917)
PRODUCT_PACKAGES += \
    xiaomi_rolex_overlay \
    xiaomi_riva_overlay \
    xiaomi_ugglite_overlay
else ifeq ($(PRODUCT_HARDWARE),Mi8937)
PRODUCT_PACKAGES += \
    xiaomi_prada_overlay \
    xiaomi_prada_overlay_Settings \
    xiaomi_ugg_overlay \
    xiaomi_wt8937_overlay \
    xiaomi_wt8937_overlay_Settings
endif

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/sku_fingerprint/android.hardware.fingerprint.xml

# Audio
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*.xml,$(LOCAL_PATH)/audio/mixer_paths/,$(TARGET_COPY_OUT_VENDOR)/etc/) \
    $(call find-copy-subdir-files,*.xml,$(LOCAL_PATH)/audio/platform_info/,$(TARGET_COPY_OUT_VENDOR)/etc/)

# Camera
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/blankfile:$(TARGET_COPY_OUT_ODM)/bin/mm-qcamera-daemon \
    $(LOCAL_PATH)/configs/blankfile:$(TARGET_COPY_OUT_ODM)/etc/camera/.placeholder

PRODUCT_PACKAGES += \
    camera.ulysse \
    camera.wingtech

ifeq ($(PRODUCT_HARDWARE),Mi8937)
PRODUCT_PACKAGES += \
    camera.land
endif

# Filesystem
PRODUCT_PACKAGES += \
    e2fsck_ramdisk \
    tune2fs_ramdisk \
    resize2fs_ramdisk

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Fingerprint
ifeq ($(PRODUCT_HARDWARE),Mi8937)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/blankfile:$(TARGET_COPY_OUT_ODM)/bin/gx_fpd

PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.1-service.xiaomi_ulysse \
    android.hardware.biometrics.fingerprint@2.1-service.xiaomi_wt8937
endif

# Input
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/keylayout/,$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/) \
    $(foreach f, msm8917-sku5-snd-card_Button_Jack.kl msm8920-sku7-snd-card_Button_Jack.kl msm8952-sku1-snd-card_Button_Jack.kl, \
        $(LOCAL_PATH)/keylayout/msm8952-snd-card-mtp_Button_Jack.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/$(f))

# Placeholder
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/blankfile:$(TARGET_COPY_OUT_ODM)/bin/.placeholder \
    $(LOCAL_PATH)/configs/blankfile:$(TARGET_COPY_OUT_ODM)/lib64/.placeholder

# Recovery
ifeq ($(PRODUCT_HARDWARE),Mi8937)
PRODUCT_COPY_FILES += \
    vendor/xiaomi/Mi8937/proprietary/vendor/bin/hvdcp_opti:$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/hvdcp_opti
endif

# Rootdir
PRODUCT_PACKAGES += \
    fstab.qcom_ramdisk \
    init.baseband.sh \
    init.xiaomi.device.rc \
    init.xiaomi.device.sh

ifeq ($(PRODUCT_HARDWARE),Mi8937)
PRODUCT_PACKAGES += \
    init.goodix.sh
endif

# Shims
PRODUCT_PACKAGES += \
    libshims_android \
    libshims_ui \
    libwui

ifeq ($(PRODUCT_HARDWARE),Mi8937)
PRODUCT_PACKAGES += \
    libbinder_shim \
    libc_mutexdestroy_shim \
    libc_pthreadts_shim \
    libfakelogprint

PRODUCT_COPY_FILES += \
    prebuilts/vndk/v32/arm64/arch-arm64-armv8-a/shared/vndk-sp/libhidlbase.so:$(TARGET_COPY_OUT_ODM)/lib64/libhidlbase-v32.so
endif

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Touch HAL
PRODUCT_PACKAGES += \
    vendor.lineage.touch@1.0-service.xiaomi_mi8937

# Wifi
ifeq ($(PRODUCT_HARDWARE),Mi8937)
PRODUCT_PACKAGES += \
    WifiOverlay_prada
endif

# Inherit from vendor blobs
ifeq ($(PRODUCT_HARDWARE),Mi8917)
$(call inherit-product, vendor/xiaomi/Mi8917/Mi8917-vendor.mk)
else ifeq ($(PRODUCT_HARDWARE),Mi8937)
$(call inherit-product, vendor/xiaomi/Mi8937/Mi8937-vendor.mk)
endif
