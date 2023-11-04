#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function patchelf_add_needed() {
    local LOCAL_PATCHELF="${PATCHELF}"
    [ -x "${3}" ] && LOCAL_PATCHELF="${3}"
    if ! "${LOCAL_PATCHELF}" --print-needed "${2}" | grep -q "${1}"; then
        "${LOCAL_PATCHELF}" --add-needed "${1}" "${2}"
    fi
}

function blob_fixup() {
    # Camera
    if [[ "${1}" =~ ^odm/overlayfs/.*/lib/libmmcamera.*\.so$ ]]; then
        sed -i 's|data/misc/camera|data/vendor/qcam|g;s|libgui.so|libwui.so|g' "${2}"
    fi

    case "${1}" in
        # Camera
        odm/overlayfs/*/bin/mm-qcamera-daemon)
            sed -i 's|data/misc/camera|data/vendor/qcam|g' "${2}"
            if [ "${1}" == "odm/overlayfs/land/bin/mm-qcamera-daemon" ]; then
                patchelf_add_needed "libshim_mutexdestroy.so" "${2}"
                patchelf_add_needed "libshim_pthreadts.so" "${2}"
            fi
            ;;
        odm/overlayfs/*/lib/libmmcamera_ppeiscore.so)
            patchelf_add_needed "libshims_ui.so"
            ;;
        odm/overlayfs/*/lib/libmmcamera2_sensor_modules.so)
            sed -i 's|/system/etc/camera/|////odm/etc/camera/|g' "${2}"
            sed -i 's|/system/vendor/lib|////vendor/odm/lib|g' "${2}"
            ;;
        odm/overlayfs/*/lib/libmmcamera2_stats_modules.so)
            "${PATCHELF}" --replace-needed "libandroid.so" "libshims_android.so" "${2}"
            ;;
        odm/overlayfs/*/lib/libmmsw_platform.so|odm/overlayfs/*/lib/libmmsw_detail_enhancement.so)
            "${PATCHELF}" --remove-needed "libbinder.so" "${2}"
            sed -i 's|libgui.so|libwui.so|g' "${2}"
            ;;
        odm/overlayfs/*/lib/libmpbase.so)
            "${PATCHELF}" --replace-needed "libandroid.so" "libshims_android.so" "${2}"
            ;;
        # Fingerprint (Legacy Goodix)
        odm/overlayfs/*/bin/gx_fpcmd|odm/overlayfs/*/bin/gx_fpd)
            "${PATCHELF_0_17_2}" --remove-needed "libbacktrace.so" "${2}"
            "${PATCHELF_0_17_2}" --remove-needed "libunwind.so" "${2}"
            patchelf_add_needed "libfakelogprint.so" "${2}" "${PATCHELF_0_17_2}"
            ;;
        odm/overlayfs/*/lib64/libfpservice.so)
            patchelf_add_needed "libbinder_shim.so" "${2}" "${PATCHELF_0_17_2}"
            ;;
        odm/overlayfs/*/lib64/hw/fingerprint.*_goodix.so)
            sed -i 's|libandroid_runtime.so|libshims_android.so\x00\x00|g' "${2}"
            patchelf_add_needed "libfakelogprint.so" "${2}" "${PATCHELF_0_17_2}"
            ;;
        odm/overlayfs/*/lib64/hw/gxfingerprint.*.so)
            patchelf_add_needed "libfakelogprint.so" "${2}" "${PATCHELF_0_17_2}"
            ;;
        # Fingerprint (ugg)
        odm/lib64/lib_fpc_tac_shared.so)
            patchelf_add_needed "libbinder_shim.so" "${2}" "${PATCHELF_0_17_2}"
            ;;
        odm/lib64/libgf_ca.so)
            sed -i 's|/system/etc/firmware|////odm/firmware/ugg|g' "${2}"
            ;;
        odm/lib64/libvendor.goodix.hardware.fingerprint@1.0.so)
            "${PATCHELF_0_17_2}" --replace-needed "libhidlbase.so" "libhidlbase-v32.so" "${2}"
            ;;
        odm/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so)
            "${PATCHELF_0_17_2}" --remove-needed "libprotobuf-cpp-lite.so" "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=Mi8937
export DEVICE_COMMON=mithorium-common
export VENDOR=xiaomi

"./../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "$@"
