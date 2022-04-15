ifneq (,$(filter $(TARGET_ARCH), arm arm64))

LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
        util/QCameraBufferMaps.cpp \
        util/QCameraCmdThread.cpp \
        util/QCameraFlash.cpp \
        util/QCameraPerf.cpp \
        util/QCameraQueue.cpp \
        util/QCameraDisplay.cpp \
        util/QCameraCommon.cpp \
        QCamera2Hal.cpp \
        QCamera2Factory.cpp

#HAL 3.0 source
LOCAL_SRC_FILES += \
        HAL3/QCamera3HWI.cpp \
        HAL3/QCamera3Mem.cpp \
        HAL3/QCamera3Stream.cpp \
        HAL3/QCamera3Channel.cpp \
        HAL3/QCamera3VendorTags.cpp \
        HAL3/QCamera3PostProc.cpp \
        HAL3/QCamera3CropRegionMapper.cpp \
        HAL3/QCamera3StreamMem.cpp

LOCAL_CFLAGS := -Wall -Wextra -Werror -Wno-unused-parameter -Wno-unused-variable

#HAL 1.0 source

ifeq ($(TARGET_SUPPORT_HAL1),false)
LOCAL_CFLAGS += -DQCAMERA_HAL3_SUPPORT
else
LOCAL_CFLAGS += -DQCAMERA_HAL1_SUPPORT
LOCAL_SRC_FILES += \
        HAL/QCamera2HWI.cpp \
        HAL/QCameraMuxer.cpp \
        HAL/QCameraMem.cpp \
        HAL/QCameraStateMachine.cpp \
        HAL/QCameraChannel.cpp \
        HAL/QCameraStream.cpp \
        HAL/QCameraPostProc.cpp \
        HAL/QCamera2HWICallbacks.cpp \
        HAL/QCameraParameters.cpp \
	HAL/CameraParameters.cpp \
        HAL/QCameraParametersIntf.cpp \
        HAL/QCameraThermalAdapter.cpp
endif

# System header file path prefix
LOCAL_CFLAGS += -DSYSTEM_HEADER_PREFIX=sys

LOCAL_CFLAGS += -DHAS_MULTIMEDIA_HINTS -D_ANDROID


ifeq (1,$(filter 1,$(shell echo "$$(( $(PLATFORM_SDK_VERSION) <= 23 ))" )))
LOCAL_CFLAGS += -DUSE_HAL_3_3
endif

#use media extension
ifeq ($(TARGET_USES_MEDIA_EXTENSIONS), true)
LOCAL_CFLAGS += -DUSE_MEDIA_EXTENSIONS
endif

#USE_DISPLAY_SERVICE from Android O onwards
#to receive vsync event from display
ifeq ($(filter OMR1 O 8.1.0, $(PLATFORM_VERSION)), )
USE_DISPLAY_SERVICE := true
LOCAL_CFLAGS += -DUSE_DISPLAY_SERVICE
endif

#HAL 1.0 Flags
LOCAL_CFLAGS += -DDEFAULT_DENOISE_MODE_ON -DHAL3 -DQCAMERA_REDEFINE_LOG

LOCAL_C_INCLUDES := \
        $(LOCAL_PATH)/../mm-image-codec/qexif \
        $(LOCAL_PATH)/../mm-image-codec/qomx_core \
        $(LOCAL_PATH)/include \
        $(LOCAL_PATH)/stack/mm-camera-interface/inc \
        $(LOCAL_PATH)/util \
        $(LOCAL_PATH)/HAL3 \
        $(call project-path-for,qcom-media)/libstagefrighthw \
        $(call project-path-for,qcom-media)/mm-core/inc \
        $(TARGET_OUT_HEADERS)/mm-camera-lib/cp/prebuilt

LOCAL_HEADER_LIBRARIES := media_plugin_headers
LOCAL_HEADER_LIBRARIES += libandroid_sensor_headers
LOCAL_HEADER_LIBRARIES += libcutils_headers
LOCAL_HEADER_LIBRARIES += libsystem_headers
LOCAL_HEADER_LIBRARIES += libhardware_headers
LOCAL_HEADER_LIBRARIES += camera_common_headers
LOCAL_HEADER_LIBRARIES += display_headers

#HAL 1.0 Include paths
LOCAL_C_INCLUDES += \
        $(LOCAL_PATH)/HAL

ifeq ($(TARGET_COMPILE_WITH_MSM_KERNEL),true)
LOCAL_C_INCLUDES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr
endif
ifeq ($(TARGET_TS_MAKEUP),true)
LOCAL_CFLAGS += -DTARGET_TS_MAKEUP
LOCAL_C_INCLUDES += $(LOCAL_PATH)/HAL/tsMakeuplib/include
endif
ifneq (,$(filter msm8974 msm8916 msm8226 msm8610 msm8916 apq8084 msm8084 msm8994 msm8992 msm8952 msm8937 msm8953 msm8996 msmcobalt msmfalcon, $(TARGET_BOARD_PLATFORM)))
    LOCAL_CFLAGS += -DVENUS_PRESENT
endif

ifneq (,$(filter msm8996 msmcobalt msmfalcon,$(TARGET_BOARD_PLATFORM)))
    LOCAL_CFLAGS += -DUBWC_PRESENT
endif

#LOCAL_STATIC_LIBRARIES := libqcamera2_util
LOCAL_C_INCLUDES += \
        $(call project-path-for,qcom-display)/libqservice
LOCAL_SHARED_LIBRARIES := liblog libhardware libutils libcutils libdl libsync
#LOCAL_SHARED_LIBRARIES += libmmcamera_interface libmmjpeg_interface libui libcamera_metadata
LOCAL_SHARED_LIBRARIES += libui libcamera_metadata
LOCAL_SHARED_LIBRARIES += libqdMetaData libqservice libbinder
ifeq ($(USE_DISPLAY_SERVICE),true)
LOCAL_SHARED_LIBRARIES += android.frameworks.displayservice@1.0 libhidlbase libhidltransport
else
LOCAL_SHARED_LIBRARIES += libgui
endif
ifeq ($(TARGET_TS_MAKEUP),true)
LOCAL_SHARED_LIBRARIES += libts_face_beautify_hal libts_detected_face_hal
endif

LOCAL_STATIC_LIBRARIES := android.hardware.camera.common@1.0-helper


LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE := camera.$(TARGET_BOARD_PLATFORM)
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_TAGS := optional

LOCAL_32_BIT_ONLY := $(BOARD_QTI_CAMERA_32BIT_ONLY)

MI8937_CAM_HAL_32_BIT_ONLY := $(LOCAL_32_BIT_ONLY)
MI8937_CAM_HAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_ADDITIONAL_DEPENDENCIES)
MI8937_CAM_HAL_CFLAGS := $(LOCAL_CFLAGS)
MI8937_CAM_HAL_C_INCLUDES := $(LOCAL_C_INCLUDES)
MI8937_CAM_HAL_HEADER_LIBRARIES := $(LOCAL_HEADER_LIBRARIES)
MI8937_CAM_HAL_MODULE := $(LOCAL_MODULE)
MI8937_CAM_HAL_MODULE_RELATIVE_PATH := $(LOCAL_MODULE_RELATIVE_PATH)
MI8937_CAM_HAL_MODULE_TAGS := $(LOCAL_MODULE_TAGS)
MI8937_CAM_HAL_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES)
MI8937_CAM_HAL_SRC_FILES := $(LOCAL_SRC_FILES)
MI8937_CAM_HAL_STATIC_LIBRARIES := $(LOCAL_STATIC_LIBRARIES)
MI8937_CAM_HAL_VENDOR_MODULE := $(LOCAL_VENDOR_MODULE)
include $(CLEAR_VARS)

include $(CLEAR_VARS)
LOCAL_32_BIT_ONLY := $(MI8937_CAM_HAL_32_BIT_ONLY)
LOCAL_ADDITIONAL_DEPENDENCIES := $(MI8937_CAM_HAL_ADDITIONAL_DEPENDENCIES)
LOCAL_CFLAGS := $(MI8937_CAM_HAL_CFLAGS)
LOCAL_C_INCLUDES := $(MI8937_CAM_HAL_C_INCLUDES)
LOCAL_HEADER_LIBRARIES := $(MI8937_CAM_HAL_HEADER_LIBRARIES)
LOCAL_MODULE_RELATIVE_PATH := $(MI8937_CAM_HAL_MODULE_RELATIVE_PATH)
LOCAL_MODULE_TAGS := $(MI8937_CAM_HAL_MODULE_TAGS)
LOCAL_SHARED_LIBRARIES := $(MI8937_CAM_HAL_SHARED_LIBRARIES)
LOCAL_SRC_FILES := $(MI8937_CAM_HAL_SRC_FILES)
LOCAL_STATIC_LIBRARIES := $(MI8937_CAM_HAL_STATIC_LIBRARIES)
LOCAL_VENDOR_MODULE := $(MI8937_CAM_HAL_VENDOR_MODULE)

ifeq ($(MI8937_CAM_USE_RENAMED_BLOBS_W),true)
LOCAL_CFLAGS += -DRENAME_BLOBS
endif

LOCAL_CFLAGS += -DODM_WINGTECH
LOCAL_SHARED_LIBRARIES += libWmcamera_interface libWmjpeg_interface
LOCAL_MODULE := camera.wingtech
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_32_BIT_ONLY := $(MI8937_CAM_HAL_32_BIT_ONLY)
LOCAL_ADDITIONAL_DEPENDENCIES := $(MI8937_CAM_HAL_ADDITIONAL_DEPENDENCIES)
LOCAL_CFLAGS := $(MI8937_CAM_HAL_CFLAGS)
LOCAL_C_INCLUDES := $(MI8937_CAM_HAL_C_INCLUDES)
LOCAL_HEADER_LIBRARIES := $(MI8937_CAM_HAL_HEADER_LIBRARIES)
LOCAL_MODULE_RELATIVE_PATH := $(MI8937_CAM_HAL_MODULE_RELATIVE_PATH)
LOCAL_MODULE_TAGS := $(MI8937_CAM_HAL_MODULE_TAGS)
LOCAL_SHARED_LIBRARIES := $(MI8937_CAM_HAL_SHARED_LIBRARIES)
LOCAL_SRC_FILES := $(MI8937_CAM_HAL_SRC_FILES)
LOCAL_STATIC_LIBRARIES := $(MI8937_CAM_HAL_STATIC_LIBRARIES)
LOCAL_VENDOR_MODULE := $(MI8937_CAM_HAL_VENDOR_MODULE)

ifeq ($(MI8937_CAM_USE_RENAMED_BLOBS_U),true)
LOCAL_CFLAGS += -DRENAME_BLOBS
endif

LOCAL_CFLAGS += -DDEVICE_ULYSSE
LOCAL_SHARED_LIBRARIES += libUmcamera_interface libUmjpeg_interface
LOCAL_MODULE := camera.ulysse
include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := camera_common_headers
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/stack/common
include $(BUILD_HEADER_LIBRARY)

include $(call first-makefiles-under,$(LOCAL_PATH))
endif
