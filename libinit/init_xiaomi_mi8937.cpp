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

static const variant_info_t ugglite_info = {
    .brand = "xiaomi",
    .device = "ugglite",
    .marketname = "",
    .model = "Redmi Note 5A",
    .build_fingerprint = "",
};

static const variant_info_t ugg_info = {
    .brand = "xiaomi",
    .device = "ugg",
    .marketname = "",
    .model = "Redmi Note 5A",
    .build_fingerprint = "",
};

static const variant_info_t rolex_info = {
    .brand = "Xiaomi",
    .device = "rolex",
    .marketname = "",
    .model = "Redmi 4A",
    .build_fingerprint = "",
};

static const variant_info_t riva_info = {
    .brand = "Xiaomi",
    .device = "riva",
    .marketname = "",
    .model = "Redmi 5A",
    .build_fingerprint = "",
};

static const variant_info_t land_info = {
    .brand = "Xiaomi",
    .device = "land",
    .marketname = "",
    .model = "Redmi 3S",
    .build_fingerprint = "",
};

static const variant_info_t santoni_info = {
    .brand = "Xiaomi",
    .device = "santoni",
    .marketname = "",
    .model = "Redmi 4X",
    .build_fingerprint = "",
};

static void determine_device_land(const std::string &proc_cmdline)
{
    set_variant_props(land_info);

    if (proc_cmdline.find("S88537AB1") != proc_cmdline.npos)
        set_ro_build_prop("model", "Redmi 3X", true);
}

static void determine_device_santoni(const std::string &proc_cmdline)
{
    set_variant_props(santoni_info);

    if (proc_cmdline.find("S88536CA2") != proc_cmdline.npos)
        set_ro_build_prop("model", "Redmi 4", true);
}

static void determine_device()
{
    std::string fdt_model, proc_cmdline;

    android::base::ReadFileToString("/proc/cmdline", &proc_cmdline, true);
    if (proc_cmdline.find("S88503") != proc_cmdline.npos) {
        set_variant_props(rolex_info);
        return;
    } else if (proc_cmdline.find("S88505") != proc_cmdline.npos) {
        set_variant_props(riva_info);
        return;
    } else if (proc_cmdline.find("S88537") != proc_cmdline.npos) {
        determine_device_land(proc_cmdline);
        return;
    } else if (proc_cmdline.find("S88536") != proc_cmdline.npos) {
        determine_device_santoni(proc_cmdline);
        return;
    }

    android::base::ReadFileToString("/sys/firmware/devicetree/base/model", &fdt_model, true);
    if (fdt_model.find("MSM8917") != fdt_model.npos)
        set_variant_props(ugglite_info);
    else if (fdt_model.find("MSM8940") != fdt_model.npos)
        set_variant_props(ugg_info);
}

void vendor_load_properties() {
    determine_device();
    set_dalvik_heap();
}
