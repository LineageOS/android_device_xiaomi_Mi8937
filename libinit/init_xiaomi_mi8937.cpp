/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <libinit_dalvik_heap.h>
#include <libinit_utils.h>
#include <libinit_variant.h>

#include "vendor_init.h"

#include <android-base/file.h>
#include <fstab/fstab.h>

static const variant_info_t ugglite_info = {
    .brand = "xiaomi",
    .device = "ugglite",
    .marketname = "",
    .model = "Redmi Note 5A",
    .build_fingerprint = "",
    .dpi = 260,
};

static const variant_info_t ugg_info = {
    .brand = "xiaomi",
    .device = "ugg",
    .marketname = "",
    .model = "Redmi Note 5A",
    .build_fingerprint = "",
    .dpi = 260,
};

static const variant_info_t rolex_info = {
    .brand = "Xiaomi",
    .device = "rolex",
    .marketname = "",
    .model = "Redmi 4A",
    .build_fingerprint = "",
    .dpi = 280,
};

static const variant_info_t riva_info = {
    .brand = "Xiaomi",
    .device = "riva",
    .marketname = "",
    .model = "Redmi 5A",
    .build_fingerprint = "",
    .dpi = 280,
};

static const variant_info_t land_info = {
    .brand = "Xiaomi",
    .device = "land",
    .marketname = "",
    .model = "Redmi 3S",
    .build_fingerprint = "",
    .dpi = 280,
};

static const variant_info_t santoni_info = {
    .brand = "Xiaomi",
    .device = "santoni",
    .marketname = "",
    .model = "Redmi 4X",
    .build_fingerprint = "",
    .dpi = 280,
};

static const variant_info_t prada_info = {
    .brand = "Xiaomi",
    .device = "prada",
    .marketname = "",
    .model = "Redmi 4",
    .build_fingerprint = "",
    .dpi = 280,
};

static void determine_device()
{
    std::string codename;

    android::base::ReadFileToString("/sys/xiaomi-msm8937-mach/codename", &codename, true);
    if (codename.empty())
        return;
    codename.pop_back();

    if (codename == "rolex") {
        set_variant_props(rolex_info);
    } else if (codename == "riva") {
        set_variant_props(riva_info);
    } else if (codename == "land") {
        set_variant_props(land_info);
        goto read_wingtech_board_id;
    } else if (codename == "santoni") {
        set_variant_props(santoni_info);
        goto read_wingtech_board_id;
    } else if (codename == "ugglite") {
        set_variant_props(ugglite_info);
    } else if (codename == "prada") {
        set_variant_props(prada_info);
    } else if (codename == "ugg") {
        set_variant_props(ugg_info);
    }

    return;

read_wingtech_board_id:
    std::string wingtech_board_id;

    android::base::ReadFileToString("/sys/xiaomi-msm8937-mach/wingtech_board_id", &wingtech_board_id, true);
    if (wingtech_board_id.empty())
        return;
    wingtech_board_id.pop_back();

    if (codename == "land" && wingtech_board_id == "S88537AB1") {
        set_ro_build_prop("model", "Redmi 3X", true);
    } else if (codename == "santoni" && wingtech_board_id == "S88536CA2") {
        set_ro_build_prop("model", "Redmi 4", true);
    }

    return;
}

static void enable_gatekeeper_uid_offset() {
    std::string boot_device = *android::fs_mgr::GetBootDevices().begin();
    if (boot_device == "soc/7864900.sdhci") {
        property_override("ro.gsid.image_running", "1");
    }
}

void vendor_load_properties() {
    determine_device();
    enable_gatekeeper_uid_offset();
    set_dalvik_heap();
}
