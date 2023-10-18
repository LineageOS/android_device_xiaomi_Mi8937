#include <android-base/file.h>
#include <android-base/properties.h>
#include "DumpstateUtil.h"

#include <fcntl.h>
#include <stdio.h>
#include <string>

using android::os::dumpstate::CommandOptions;
using android::os::dumpstate::DumpFileToFd;
using android::base::GetProperty;
using android::base::ReadFileToString;
using android::base::SetProperty;

#define ARRAY_SIZE(array)   sizeof(array) / sizeof(array[0])

// Example: /sys/devices/platform/soc/78b7000.i2c/i2c-3/3-003e
#define I2C_DEV_PATH(bus_reg, bus_num, dev_reg) "/sys/devices/platform/soc/" \
    bus_reg ".i2c" "/" \
    "i2c-" bus_num "/" \
    bus_num "-" dev_reg

enum touchscreen_types {
    TS_ATMEL,
    TS_FTS,
    TS_GOODIX,
    TS_IST30XX,
};

typedef struct touchscreen {
    const enum touchscreen_types type;
    const char* path;
} touchscreen_t;

static const char* touchscreen_i2c_atmel_nodes[] = {
    "build",
    "update_fw",
    "version",
};

static const char* touchscreen_i2c_focaltech_nodes[] = {
    "fts_boot_mode",
    "fts_charger_mode",
    "fts_cover_mode",
    "fts_driver_info",
    "fts_dump_reg",
    "fts_esd_mode",
    "fts_fw_version",
    "fts_gesture_buf",
    "fts_gesture_mode",
    "fts_glove_mode",
    //"fts_hw_reset", // This triggers hardware reset
    "fts_irq",
    "fts_log_level",
    "fts_report_rate",
    //"fts_rw_reg", // For reading or setting reg
    "fts_touch_point",
};

static const char* touchscreen_i2c_ist30xx_nodes[] = {
    "version",
};

static const touchscreen_t touchscreen_i2c_paths[] = {
    {TS_ATMEL, I2C_DEV_PATH("78b7000", "3", "004a")}, // prada
    {TS_FTS, I2C_DEV_PATH("78b7000", "3", "0038")}, // prada, riva, rolex, santoni, ugg, ugglite
    {TS_FTS, I2C_DEV_PATH("78b7000", "3", "003e")}, // land, santoni
    {TS_GOODIX, I2C_DEV_PATH("78b7000", "3", "005d")}, // riva, rolex, ugg, ugglite
    {TS_IST30XX, I2C_DEV_PATH("78b7000", "3", "0050")}, // land
};

static void dumpNodes(const int fd, const char* title, const char* basepath, const char* nodes[], int nodes_cnt) {
    char title_buf[64], path_buf[128];
    for (int i = 0; i < nodes_cnt; i++) {
        snprintf(title_buf, sizeof(title_buf), "%s: %s", title, nodes[i]);
        snprintf(path_buf, sizeof(path_buf), "%s/%s", basepath, nodes[i]);
        DumpFileToFd(fd, std::string(title_buf), std::string(path_buf));
    }
    return;
}

static bool isPathReadable(const char* path) {
    int fd = open(path, O_RDONLY);
    if (fd < 0) {
        return false;
    } else {
        close(fd);
        return true;
    }
}

extern "C" void dumpstate_device_handler(const int fd, [[maybe_unused]] const bool full) {
    char tempCStr[128];
    std::string mach_codename, tempStr;

    dprintf(fd, "====== Enter device handler ======\n");

    // Mach info
    ReadFileToString("/sys/xiaomi-msm8937-mach/codename", &mach_codename);
    mach_codename.pop_back();
    DumpFileToFd(fd, "Mach codename", "/sys/xiaomi-msm8937-mach/codename");
    DumpFileToFd(fd, "Mach wingtech board id", "/sys/xiaomi-msm8937-mach/wingtech_board_id");

    // Camera
    DumpFileToFd(fd, "Camera fusion id (Front)", "/sys/camera_fusion_id_front/fusion_id_front");
    DumpFileToFd(fd, "Camera fusion id (Back)", "/sys/camera_fusion_id_back/fusion_id_back");

    // Hardware region
    if (mach_codename == "ugg" || mach_codename == "ugglite") {
        tempStr = GetProperty("ro.boot.hwcountry", "");
        dprintf(fd, "------ Hardware region (ro.boot.hwcountry) ------\n");
        dprintf(fd, "%s\n", tempStr.c_str());
        dprintf(fd, "\n");
    }

    // Fingerprint
    dprintf(fd, "------ Fingerprint variant ------\n");
    if (mach_codename == "ugg") {
        // Redmi Note 5A / Y1 Prime (ugg)
        tempStr = GetProperty("ro.boot.fpsensor", "");
        if (tempStr == "fpc")
            dprintf(fd, "FPC\n");
        else if (tempStr == "gdx")
            dprintf(fd, "Goodix\n");
        else
            dprintf(fd, "Invalid\n");
    } else if (mach_codename == "land" || mach_codename == "santoni" || mach_codename == "prada") {
        // Devices with legacy Goodix fingerprint daemon
        tempStr = GetProperty("persist.sys.fp.vendor", "");
        if (tempStr == "switchf")
            dprintf(fd, "FPC\n");
        else if (tempStr == "goodix")
            dprintf(fd, "Goodix\n");
        else
            dprintf(fd, "Invalid\n");
    }
    dprintf(fd, "\n");

    // Touchscreen
    for (auto &ts : touchscreen_i2c_paths) {
        snprintf(tempCStr, sizeof(tempCStr), "%s/input/", ts.path);
        if (isPathReadable(tempCStr)) {
            switch (ts.type) {
                case TS_ATMEL:
                    dumpNodes(fd, "Touchscreen (Atmel)", ts.path, touchscreen_i2c_atmel_nodes, ARRAY_SIZE(touchscreen_i2c_atmel_nodes));
                    break;
                case TS_FTS:
                    dumpNodes(fd, "Touchscreen (FocalTech)", ts.path, touchscreen_i2c_focaltech_nodes, ARRAY_SIZE(touchscreen_i2c_focaltech_nodes));
                    break;
                case TS_GOODIX:
                    // Goodix touchscreen has no sysfs node
                    dprintf(fd, "------ Touchscreen (Goodix) ------\n");
                    break;
                case TS_IST30XX:
                    dumpNodes(fd, "Touchscreen (IST30xx)", ts.path, touchscreen_i2c_ist30xx_nodes, ARRAY_SIZE(touchscreen_i2c_ist30xx_nodes));
                    break;
            }
        }
    }

    // Touchscreen sysctl
    DumpFileToFd(fd, "Touchscreen sysctl: Disable keys", "/proc/sys/dev/xiaomi_msm8937_touchscreen/disable_keys");
    DumpFileToFd(fd, "Touchscreen sysctl: Enable DT2W", "/proc/sys/dev/xiaomi_msm8937_touchscreen/enable_dt2w");

    // Touchscreen virtualkeys
    DumpFileToFd(fd, "Touchscreen virtualkeys: ist30xx_ts_input", "/sys/board_properties/virtualkeys.ist30xx_ts_input");

    /* Restart services (To make their early logs appear again on logcat) */
    // Fingerprint
    if (mach_codename == "ugg") {
        // Redmi Note 5A / Y1 Prime (ugg)
        SetProperty("ctl.restart", "vendor.fps_hal.ulysse");
    } else if (mach_codename == "land" || mach_codename == "santoni" || mach_codename == "prada") {
        // Devices with legacy Goodix fingerprint daemon
        SetProperty("ctl.stop", "vendor.fps_hal.wt8937");
        SetProperty("ctl.stop", "vendor.gx_fpd");
        SetProperty("ctl.start", "vendor.gx_fpd");
        usleep(500000);
        SetProperty("ctl.start", "vendor.fps_hal.wt8937");
    }
    usleep(500000);

    return;
}
