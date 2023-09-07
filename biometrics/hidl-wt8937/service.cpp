/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "android.hardware.biometrics.fingerprint@2.1-service"

#include <android/log.h>
#include <android-base/file.h>
#include <android-base/properties.h>
#include <binder/ProcessState.h>
#include <hidl/HidlSupport.h>
#include <hidl/HidlTransportSupport.h>
#include <android/hardware/biometrics/fingerprint/2.1/IBiometricsFingerprint.h>
#include <android/hardware/biometrics/fingerprint/2.1/types.h>
#include "BiometricsFingerprint.h"
#include "gf_ioctl.h"
#include <errno.h>
#include <unistd.h>

#define FPC_ATTR(attr)  "/sys/devices/soc/soc:fpc1020/" attr

bool is_goodix = false;
bool use_cancel_hack = true;
std::string fp_vendor;

static constexpr char kGoodixFpDev[] = "/dev/goodix_fp";

using android::hardware::biometrics::fingerprint::V2_1::IBiometricsFingerprint;
using android::hardware::biometrics::fingerprint::V2_1::implementation::BiometricsFingerprint;
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;
using android::sp;

static void fpc_enable(bool enable)
{
    if (enable) {
        if (!android::base::WriteStringToFile("enable", FPC_ATTR("compatible_all"), true))
            ALOGE("Failed to enable fpc1020 driver.");
        else
            if (!android::base::WriteStringToFile("enable", FPC_ATTR("spi_prepare"), true))
                ALOGE("Failed to prepare spi for fpc1020.");
    } else {
        if (!android::base::WriteStringToFile("disable", FPC_ATTR("spi_prepare"), true))
            ALOGE("Failed to unprepare spi for fpc1020.");
        if (!android::base::WriteStringToFile("disable", FPC_ATTR("compatible_all"), true))
            ALOGE("Failed to disable fpc1020 driver.");
    }
}

int main() {
    int fd, val;

    fp_vendor = android::base::GetProperty("persist.sys.fp.vendor","");

    if (fp_vendor == "goodix") {
        is_goodix = true;
        ALOGD("Enable workarounds for goodix.");
    }
    if (android::base::GetProperty("vendor.fingerprint.disable_notify_cancel_hack","") == "1") {
        use_cancel_hack = false;
        ALOGD("Disable notify client on cancel hack.");
    }

    if (!is_goodix) {
        fd = open(kGoodixFpDev, 0);
        if (fd < 0) {
            ALOGE("Failed to open goodix fp device for cleanup.");
        } else {
            val = 1;
            if (ioctl(fd, GF_IOC_RESET, &val) < 0)
                ALOGE("Failed to ioctl GF_IOC_RESET on goodix fp device.");
            if (ioctl(fd, GF_IOC_DISABLE_IRQ, &val) < 0)
                ALOGE("Failed to ioctl GF_IOC_DISABLE_IRQ on goodix fp device.");
            if (ioctl(fd, GF_IOC_RELEASE_GPIO, &val) < 0)
                ALOGE("Failed to ioctl GF_IOC_RELEASE_GPIO on goodix fp device.");

            close(fd);
        }
    }

    if (fp_vendor == "switchf")
        fpc_enable(true);
    else
        fpc_enable(false);

    android::sp<IBiometricsFingerprint> bio = BiometricsFingerprint::getInstance();

    if (is_goodix) {
        if (access(kGoodixFpDev, F_OK) != 0) {
            ALOGE("Cannot access %s (%s)", kGoodixFpDev, strerror(errno));
            return 1;
        }
        // the conventional HAL might start vndbinder services
        android::ProcessState::initWithDriver("/dev/vndbinder");
        android::ProcessState::self()->startThreadPool();
    }

    configureRpcThreadpool(1, true /*callerWillJoin*/);

    if (bio != nullptr) {
        if (::android::OK != bio->registerAsService()) {
            return 1;
        }
    } else {
        ALOGE("Can't create instance of BiometricsFingerprint, nullptr");
    }

    joinRpcThreadpool();

    return 0; // should never get here
}
