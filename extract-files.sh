#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        lib*/vendor.huawei.hardware.libteec@2.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/bin/hw/wpa_supplicant)
            "${PATCHELF}" --add-needed "libcompiler_rt-v29.so" "${2}"
            ;;
        vendor/bin/hw/hostapd)
            "${PATCHELF}" --add-needed "libcompiler_rt-v29.so" "${2}"
            ;;
        vendor/lib*/hw/audio.primary.mt6765.so)
            "${PATCHELF}" --replace-needed "libmedia_helper.so" "libmedia_helper-v28.so" "${2}"
            "${PATCHELF}" --replace-needed "libxml2.so" "libxml2-v28.so" "${2}"
            ;;
        vendor/lib*/hw/vendor.mediatek.hardware.pq@2.2-impl.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v32.so" "${2}"
            ;;
        vendor/lib*/libnvram.so)
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
        vendor/lib*/libwvhidl.so)
            "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite.so" "libprotobuf-cpp-lite-v29.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.camera.camResource@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.camera.camResource@1.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.camera.cfgsvr@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.camera.cfgsvr@1.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.camera.factory@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.hisiradio@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.sensors@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.libteec@2.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.radio.chr@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.radio.deprecated@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.radio.ims@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.radio@2.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.huawei.hardware.radioenhance@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.camera.callbackclient@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.camera.callbackclient@1.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.camera.ccap@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.camera.lomoeffect@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.dfps@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.gnss@1.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.mms@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.mms@1.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.nvram@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.nvram@1.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.power@2.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.pq@2.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.pq@2.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.pq@2.2.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.radio_ex@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.radio_ex@1.1.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.radio_radar@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/lib*/vendor.mediatek.hardware.videotelephony@1.0.so)
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
    esac
}

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"
