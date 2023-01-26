#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

export DEVICE=Mi8917
export DEVICE_PARENT=Mi8937
export DEVICE_COMMON=mithorium-common
export VENDOR=xiaomi

MY_DIR="$(cd "$(dirname "${0}")"; pwd -P)"

"${MY_DIR}/../../../${VENDOR}/${DEVICE_COMMON}/setup-makefiles.sh" "$@"
